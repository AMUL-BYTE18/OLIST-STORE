-- KPI 1 Weekday Vs Weekend Payment Statistics 
SELECT 
kpi1.weekend_vs_weekday,
concat(round(kpi1.total_payment /(SELECT sum(payment_value) FROM olist_order_payments_dataset)*100,2),
'%') AS `% payment_values`
FROM
(SELECT ord.weekend_vs_weekday, sum(pmt.payment_value) AS total_payment
FROM olist_order_payments_dataset AS pmt
JOIN 
(SELECT DISTINCT order_id,
CASE 
WHEN Weekday(order_purchase_timestamp) IN (5,6) THEN 'Weekend'
ELSE 'Weekday'
END AS weekend_vs_weekday
FROM olist_orders_dataset) AS ord
ON ord.order_id = pmt.order_id
GROUP BY ord.weekend_vs_weekday) AS kpi1;

-- KPI 2 No Of Orders with Reviwe Score 5 And Payment Type as Credit Card 
SELECT
COUNT(pmt.order_id) AS Total_Orders
FROM olist_order_payments_dataset pmt
INNER JOIN olist_order_reviews_dataset AS rev ON pmt.order_id = rev.order_id
WHERE rev.review_score = 5
AND pmt.payment_type = 'credit_card';

-- KPI 3 NO  Average no of days taken for delivery for pet shop 
SELECT 
prd.product_category_name,
ROUND(AVG(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp))) AS Avg_Delivery_Days
FROM olist_orders_dataset ord
JOIN 
(SELECT product_id,order_id,product_category_name
FROM olist_products_dataset
JOIN olist_order_items_dataset USING (product_id)) AS prd
ON ord.order_id = prd.order_id
WHERE prd.product_category_name = 'pet_shop'
GROUP BY prd.product_category_name;

-- KPI 4 -- Average price and payment from sao paulo city 
-------------------------------
SELECT 
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM olist_customers_dataset c
JOIN  olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
WHERE c.customer_city = 'sao paulo';

-----------------------------------------
SELECT 
    ROUND(AVG(op.payment_value), 2) AS avg_payment_value
FROM olist_customers_dataset c
JOIN  olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN  olist_order_payments_dataset op 
    ON o.order_id = op.order_id
WHERE c.customer_city = 'sao paulo';
----------------------------------------------------
-- Another way To Get This 

WITH sao_paulo_orders AS (
    SELECT 
        o.order_id
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
	ON c.customer_id = o.customer_id
	WHERE c.customer_city = 'sao paulo'
),

avg_price AS (
    SELECT 
        ROUND(AVG(price), 2) AS avg_product_price
    FROM olist_order_items_dataset
    WHERE order_id IN (SELECT order_id FROM sao_paulo_orders)
),
avg_payment AS (
    SELECT 
        ROUND(AVG(payment_value), 2) AS avg_payment_value
    FROM olist_order_payments_dataset
    WHERE order_id IN (SELECT order_id FROM sao_paulo_orders)
)
SELECT 
    'Sao Paulo' AS customer_city,
    ap.avg_product_price,
    pay.avg_payment_value
FROM avg_price ap
CROSS JOIN avg_payment pay;

-- KPI 5 -- Relationshi between Shipping Days 

SELECT 
rev.review_score,
round(AVG(datediff(ord.order_delivered_customer_date,order_purchase_timestamp)),0) AS 'Shipping_Days'
FROM olist_orders_dataset AS ord
JOIN olist_order_reviews_dataset AS rev ON rev.order_id = ord.order_id
GROUP BY rev.review_score
ORDER BY rev.review_score;

  









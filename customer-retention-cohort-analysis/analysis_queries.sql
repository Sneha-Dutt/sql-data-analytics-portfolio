-- Monthly Orders

SELECT
DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;


-- First Purchase Per Customer

SELECT
customer_id,
MIN(order_purchase_timestamp) AS first_purchase
FROM orders
GROUP BY customer_id;

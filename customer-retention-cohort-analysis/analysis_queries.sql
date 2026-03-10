## Monthly Orders

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
-- -------------------------------------------------------------------------------------------------------------------
create database project1;
use project1;

-- renaming the tables inyo more readable format

alter table olist_customers_dataset rename customers;
alter table olist_order_items_dataset rename order_items;
alter table olist_order_payments_dataset rename payments;
alter table olist_orders_dataset rename orders;
-- -------------------------------------------------------------------------------------------------------------------

-- DATA EXPLORATION QUERIES (EDA)
-- Total orders
select count(*) as total_orders from orders;
-- this displays the overall transaction volume of the dataset. The dataset has ~100k orders, providing sufficient 
-- data for customer behaviour analysis.
-- ------------------------------------------------------------------------------------------------------------------

-- Total customers
select count(distinct customer_unique_id) from customers;
-- This displays the volume of the customers dataset. This can be useful in assessing the customer engagement.
-- ------------------------------------------------------------------------------------------------------------------

-- Orders by order_status:
select order_status, count(*) as total_orders
from orders
group by order_status
order by count(*) desc;
-- This helps us identify the number of successful deliveries, cancelled orders, operational issues, etc.
-- It can be seen that majority of the orders were delivered successfully.
-- ------------------------------------------------------------------------------------------------------------------

-- Orders per month
select date_format(order_purchase_timestamp, '%Y-%m') as order_month, count(*) as number_of_orders
from orders
group by date_format(order_purchase_timestamp, '%Y-%m')
order by date_format(order_purchase_timestamp, '%Y-%m');
-- This shows seasonal demand patterns
-- Order volumes increase toward the end of the year, maybe due to holiday shopping.
-- ------------------------------------------------------------------------------------------------------------------

-- Revenue analysis
select round(sum(payment_value),2) as total_payments from payments;
-- Total revenue generated in the dataset provides an overview of the platform’s sales scale.
-- ------------------------------------------------------------------------------------------------------------------

-- CUSTOMER PURCHASE ANALYSIS
-- Orders per customer
select c.customer_unique_id, count(o.order_id) as orders_placed 
from orders o join customers c
on o.customer_id=c.customer_id
group by c.customer_unique_id
order by count(o.order_id) desc
limit 10;
-- It can be seen that all the customers placed exactly 1 order.
-- ------------------------------------------------------------------------------------------------------------------

-- Average order per customers
select round(count(o.order_id)/count(distinct c.customer_unique_id),2) as avg_orders_per_customer
from orders o join customers c
on o.customer_id=c.customer_id;
-- This metric shows how frequently the customers return back to place orders.
-- ------------------------------------------------------------------------------------------------------------------

-- Distribution of customers by order count
with cte as (
select c.customer_unique_id, count(o.order_id) as total_orders
from customers c join orders o 
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select total_orders, count(*) as number_of_customers
from cte
group by total_orders
order by total_orders;
-- This indicates very low customer retention.
-- ------------------------------------------------------------------------------------------------------------------

-- Repeat customer rate
with cte as(
select c.customer_unique_id, count(o.order_id) as total_orders
from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select sum(case when total_orders>1 then 1 else 0 end)*100/count(*) as repeat_customer_rate
from cte;
-- This shows that most customers purchase only once
-- ------------------------------------------------------------------------------------------------------------------

-- Monthly new customers
with cte as (
select c.customer_unique_id, min(o.order_purchase_timestamp) as first_purchase_date
from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select date_format(first_purchase_date,'%Y-%m') as month, count(distinct customer_unique_id) as new_customers
from cte
group by month
order by month;
-- This tracks customers acquisition growth
-- ------------------------------------------------------------------------------------------------------------------

-- Top 10 customers ordered by total payments and no. of orders
select c.customer_unique_id, count(o.order_id), sum(p.payment_value) as total_payment, 
sum(p.payment_value)*100/(select sum(payment_value) from payments) as percentage_of_payment_contributed
from customers c join orders o
on c.customer_id=o.customer_id
join payments p 
on o.order_id=p.order_id
group by c.customer_unique_id
order by sum(p.payment_value) desc, count(o.order_id) desc
limit 10;
-- This identifies the high value customers. Also shows the % contribution to the total revenue by the high value 
-- customers and also the number od orders made by them.
-- ------------------------------------------------------------------------------------------------------------------

-- Revenue generated by top 10 customers
with cte as(
select c.customer_unique_id, sum(p.payment_value) as total_revenue
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
)
select customer_unique_id, total_revenue
from cte
order by total_revenue desc
limit 10;
-- Identifies the revenues generated by the top 10 customers.
-- ------------------------------------------------------------------------------------------------------------------

-- Total revenue of top 25000 customers
with cte as 
(select c.customer_unique_id, sum(p.payment_value) as total_revenue
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on o.order_id=p.order_id
group by c.customer_unique_id)
select round(sum(total_revenue),2) as revenue_top_10, 
round(sum(total_revenue)*100/(select sum(total_revenue) from cte),2) as percentage_contribution_of_top10_to_total
from (
select total_revenue
from cte
order by total_revenue desc
limit 25000)t ;
-- Top 25000 customers contribute to ~60% of the total revenue.
-- ------------------------------------------------------------------------------------------------------------------
-- To identify customers with more than 3 orders
select c.customer_unique_id, count(o.order_id) as number_of_orders
from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_unique_id
having count(o.order_id)>3
order by count(o.order_id) desc;
-- These are the loyal customers
-- ------------------------------------------------------------------------------------------------------------------

-- COHORT RETENTION ANALYSIS
-- To identify the first purchase month per customer (Customer cohort)
with cte1 as(
select c.customer_unique_id, min(date_format(o.order_purchase_timestamp,'%Y-%m-%d')) as first_purchase
from orders o join customers c
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select * from cte1;
-- This shows when each customer entered the platform.
-- ------------------------------------------------------------------------------------------------------------------

-- Assigning customers to cohorts
with cte1 as (
select c.customer_unique_id, min(date_format(o.order_purchase_timestamp, '%Y-%m-%d')) as first_purchase
from orders o join customers c
on c.customer_id=o.customer_id
group by c.customer_unique_id
)
select customer_unique_id, date_format(first_purchase,'%Y-%m') as cohort_month
from cte1;
-- ------------------------------------------------------------------------------------------------------------------

-- Cohort Retention Table:
select * from customers;
select * from orders;

with cte1 as(
select c.customer_unique_id, min(o.order_purchase_timestamp) as first_order
from customers c join orders o 
on c.customer_id=o.customer_id
group by c.customer_unique_id
),
cte2 as (
select c.customer_unique_id,
date_format(c1.first_order,'%Y-%m') as cohort_month,
timestampdiff(month, c1.first_order, o.order_purchase_timestamp) as month_number
from customers c join orders o
on c.customer_id=o.customer_id
join cte1 c1
on c1.customer_unique_id=c.customer_unique_id
)
select cohort_month, month_number, count(distinct customer_unique_id) as retained_customers
from cte2
group by cohort_month, month_number
order by cohort_month, month_number;
-- It can be seen that the number of retained customers for month 0 is maximum- representing the first time buyers,
-- after which there is sharp decline in this number
-- ------------------------------------------------------------------------------------------------------------------

-- Customer Lifetime Value Table:
select c.customer_unique_id, count(distinct o.order_id) as total_orders, sum(p.payment_value) as lifetime_revenue,
round(sum(p.payment_value)/count(distinct o.order_id),2) as average_order_value
from customers c join orders o 
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
order by lifetime_revenue desc;
-- A small percentage of customers generate a disproportionately high share of revenue.
-- Most customers make only one purchase, limiting lifetime value.
-- Improving customer retention could significantly increase overall CLTV.
-- ------------------------------------------------------------------------------------------------------------------

-- Average customer lifetime value
with cte as 
(select c.customer_unique_id, sum(p.payment_value) as revenue
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id)
select round(avg(revenue),2) as average_cltv from cte;
-- ------------------------------------------------------------------------------------------------------------------
-- Ranking customers by values
select c.customer_unique_id, sum(p.payment_value) as lifetime_value, 
dense_rank() over(order by sum(p.payment_value) desc) as ranking
from customers c join orders o 
on c.customer_id=o.customer_id
join payments p
on o.order_id=p.order_id
group by c.customer_unique_id;

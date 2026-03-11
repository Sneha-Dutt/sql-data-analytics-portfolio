use project1;

-- Problem 1: Calculate RFM Metrics for Each Customer
-- RFM stands for:
-- Recency → How recently the customer made a purchase
-- Frequency → Number of orders
-- Monetary → Total money spent
with cte as 
(
select c.customer_unique_id, round(sum(p.payment_value),2) as revenue, max(o.order_purchase_timestamp) as most_recent_order,
count(distinct o.order_id) as number_of_orders
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
)
select customer_unique_id, most_recent_order, revenue, number_of_orders
from cte
order by number_of_orders desc;

with cte as 
(
select c.customer_unique_id, round(sum(p.payment_value),2) as revenue, max(o.order_purchase_timestamp) as most_recent_order,
count(distinct o.order_id) as number_of_orders
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
)
select count(distinct customer_unique_id) as number_of_customers_analyzed, 
round(avg(revenue),2) as average_customer_spending, 
round(max(revenue),2) as highest_customer_revenue
from cte;
-- Total customers analyzed: ~96k
-- Average customer spending: ~R$167
-- Highest customer revenue: R$13664.08
-- ------------------------------------------------------------------------------------------------------------------

-- Problem 2: Calculate Recency (Days Since Last Purchase)
-- logic: find the difference between the most recent purchase for each customer and the most recent date in the 
-- entire dataset
with cte as
(
select c.customer_unique_id, sum(p.payment_value) as monetory,
count(distinct o.order_id) as frequency,
max(o.order_purchase_timestamp) as last_order_date
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
)
select customer_unique_id, monetory, frequency,
datediff((select max(order_purchase_timestamp) from orders), last_order_date) as recency_days
from cte
order by recency_days desc;
-- Some customers have not purchased for > 500 days, indicating potential churn risk.
-- ------------------------------------------------------------------------------------------------------------------

-- Create RFM Scores using NTILE
with cte as
(
select c.customer_unique_id, 
datediff((select max(order_purchase_timestamp) from orders), max(o.order_purchase_timestamp)) as recency,
count(distinct o.order_id) as frequency,
sum(p.payment_value) as monetory
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
),cte2 as
(
select *, ntile(5) over(order by recency) as r_score,
ntile(5) over(order by frequency desc) as f_score,
ntile(5) over(order by monetory desc) as m_score
from cte
)
select * from cte2;
-- ------------------------------------------------------------------------------------------------------------------

-- Create Customer Segments
with cte as
(
select c.customer_unique_id, sum(p.payment_value) as monetory,
datediff((select max(order_purchase_timestamp) from orders), max(o.order_purchase_timestamp)) as recency,
count(distinct o.order_id) as frequency
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on p.order_id=o.order_id
group by c.customer_unique_id
),
cte2 as
(
select *, ntile(5) over(order by monetory desc) as m_score,
ntile(5) over(order by frequency desc) as f_score,
ntile(5) over(order by recency) as r_score
from cte
)
select customer_unique_id,
case
when r_score>=4 and f_score>=4 then 'Champions'
when r_score>=3 and f_score>=3 then 'Loyal Customers'
when r_score>=3 and f_score<=2 then 'Potential Loyalists'
when r_score<=2 and f_score>=3 then 'At Risk'
else 'Others'
end
as segment
from cte2;   
-- ------------------------------------------------------------------------------------------------------------------

-- Revenue Contribution by Customer Segments
with cte as
(
select c.customer_unique_id, sum(p.payment_value) as monetory,
datediff((select max(order_purchase_timestamp) from orders), max(o.order_purchase_timestamp)) as recency,
count(distinct o.order_id) as frequency
from customers c join orders o
on c.customer_id=o.customer_id
join payments p
on o.order_id=p.order_id
group by c.customer_unique_id
), cte2 as
(
select *, 
ntile(5) over(order by recency) as r_score,
ntile(5) over(order by monetory desc) as m_score,
ntile(5) over(order by frequency desc) as f_score
from cte
), cte3 as
(
select *,
case
when r_score>=4 and f_score>=4 then 'Champions'
when r_score>=3 and f_score>=3 then 'Loyal Customers'
when r_score>=3 and f_score<=2 then 'Potential Loyalists'
when r_score<=2 and f_score>=3 then 'At Risk'
else 'Others'
end
as segment
from cte2
)
select segment, round(sum(monetory),2) as revenue_contributed, count(*) as number_of_customers,
round(count(*)*100/(select count(distinct customer_unique_id) from customers),2) as percentage_of_total_customers,
round(sum(monetory)*100/(select sum(monetory) from cte),2) as percentage_of_total_revenue
from cte3
group by segment
order by revenue_contributed desc;

-- ------------------------------------------------------------------------------------------------------------------


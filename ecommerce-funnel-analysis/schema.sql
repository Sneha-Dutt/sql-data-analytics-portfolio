CREATE TABLE customers(
customer_id VARCHAR(50),
customer_unique_id VARCHAR(50),
customer_city VARCHAR(50),
customer_state VARCHAR(10)
);

CREATE TABLE orders(
order_id VARCHAR(50),
customer_id VARCHAR(50),
order_status VARCHAR(20),
order_purchase_timestamp DATETIME
);

CREATE TABLE order_items(
order_id VARCHAR(50),
order_item_id INT,
product_id VARCHAR(50),
price DECIMAL(10,2)
);

CREATE TABLE payments(
order_id VARCHAR(50),
payment_type VARCHAR(20),
payment_value DECIMAL(10,2)
);

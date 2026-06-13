create database saas_bi;
use saas_bi;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    signup_date DATE,
    country VARCHAR(50)
); 



DROP TABLE subscriptions;

CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    plan_name VARCHAR(50),
    monthly_price DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
) ENGINE=InnoDB;


CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

create table product_usage (
usage_id int auto_increment primary key,
customer_id int,
usage_date date,
login_count int,
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
);


CREATE TABLE support_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    created_at DATETIME,
    resolved_at DATETIME,
    status VARCHAR(20),

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);
 
 create table marketing_campaigns (
 campaign_id int auto_increment primary key,
 campaign_name varchar(50),
 spend decimal (10,2),
 leads_generated int,
 campaign_date date
 );
 
 INSERT INTO customers
(customer_name,email,signup_date,country)
VALUES
('John Smith','john@gmail.com','2024-01-05','USA'),
('Sarah Lee','sarah@gmail.com','2024-02-12','Canada'),
('Mike Ross','mike@gmail.com','2024-03-10','UK');

INSERT INTO subscriptions
(customer_id,plan_name,monthly_price,start_date,end_date,status)
VALUES
(1,'Pro',99,'2024-01-05',NULL,'Active'),
(2,'Basic',49,'2024-02-12',NULL,'Active'),
(3,'Pro',99,'2024-03-10','2024-10-01','Cancelled');


INSERT INTO payments
(customer_id,payment_date,amount)
VALUES
(1,'2025-01-01',99),
(1,'2025-02-01',99),
(2,'2025-02-01',49),
(3,'2025-03-01',99);

select 
sum(monthly_price) as MRR
from subscriptions
where status='Active';


select
sum(monthly_price)*12 as ARR
from subscriptions
where status='Active';


select
count(*) as active_customers
from subscriptions
where status='Active';



SELECT
ROUND(
(
COUNT(CASE WHEN status='Cancelled' THEN 1 END)
/
COUNT(*)
)*100,2
) AS churn_rate
FROM subscriptions;

SELECT
DATE_FORMAT(signup_date,'%Y-%m') AS month,
COUNT(*) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

SELECT
customer_id,
COUNT(*) AS payments_count
FROM payments
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
c.customer_id,
c.customer_name,
SUM(p.amount) AS customer_lifetime_value
FROM customers c
JOIN payments p
ON c.customer_id=p.customer_id
GROUP BY c.customer_id,c.customer_name;

WITH customer_cohort AS
(
SELECT
customer_id,
DATE_FORMAT(signup_date,'%Y-%m') AS cohort_month
FROM customers
)
SELECT *
FROM customer_cohort;


WITH cohort_data AS
(
SELECT
customer_id,
DATE_FORMAT(signup_date,'%Y-%m') AS cohort_month
FROM customers
)
SELECT
cohort_month,
COUNT(*) AS customers
FROM cohort_data
GROUP BY cohort_month;

SELECT
DATE_FORMAT(payment_date,'%Y-%m') AS month,
SUM(amount) AS revenue,

SUM(SUM(amount))
OVER(
ORDER BY DATE_FORMAT(payment_date,'%Y-%m')
) AS cumulative_revenue

FROM payments
GROUP BY month;

SELECT
payment_date,
SUM(amount)
OVER(
ORDER BY payment_date
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
) AS rolling_30_day_revenue
FROM payments;


SELECT
usage_date,
COUNT(DISTINCT customer_id) AS active_users
FROM product_usage
GROUP BY usage_date;

SELECT
DATE_FORMAT(usage_date,'%Y-%m') AS month,
COUNT(DISTINCT customer_id) AS MAU
FROM product_usage
GROUP BY month;



SELECT
AVG(
TIMESTAMPDIFF(
HOUR,
created_at,
resolved_at
)
) AS avg_resolution_hours
FROM support_tickets
WHERE status='Resolved';

SELECT
DATE(created_at) AS day,
COUNT(*) AS total_tickets
FROM support_tickets
GROUP BY day;

SELECT
SUM(spend) /
(
SELECT COUNT(*)
FROM customers
)
AS CAC
FROM marketing_campaigns;

SELECT

(SELECT SUM(monthly_price)
FROM subscriptions
WHERE status='Active') AS MRR,

(SELECT SUM(monthly_price)*12
FROM subscriptions
WHERE status='Active') AS ARR,

(
SELECT ROUND(
COUNT(CASE WHEN status='Cancelled' THEN 1 END)
/
COUNT(*)*100,2
)
FROM subscriptions
) AS ChurnRate,

(
SELECT COUNT(*)
FROM subscriptions
WHERE status='Active'
) AS ActiveCustomers;








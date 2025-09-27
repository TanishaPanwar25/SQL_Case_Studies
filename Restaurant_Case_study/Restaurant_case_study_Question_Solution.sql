CREATE database restaurant_case_study;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales (customer_id, order_date, product_id) VALUES
  ('A', '2025-01-01', 1),
  ('A', '2025-01-01', 2),
  ('A', '2025-01-07', 2),
  ('A', '2025-01-10', 3),
  ('A', '2025-01-11', 3),
  ('A', '2025-01-11', 3),
  ('B', '2025-01-01', 2),
  ('B', '2025-01-02', 2),
  ('B', '2025-01-04', 1),
  ('B', '2025-01-11', 1),
  ('B', '2025-01-16', 3),
  ('B', '2025-02-01', 3),
  ('C', '2025-01-01', 3),
  ('C', '2025-01-01', 3),
  ('C', '2025-01-07', 3);

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(20),
  price INTEGER
);

INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'biryani', 10),
  (2, 'paneer', 15),
  (3, 'dosai', 12);

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2025-01-07'),
  ('B', '2025-01-09');
select * from menu;
select * from members;
select * from sales;
-- 1. Total amount spent by each customer
select s.customer_id,sum(m.price) AS total_spend
from menu m join sales s on m.product_id=s.product_id
group by s.customer_id order by customer_id;
-- 2. Number of distinct visit days per customer
select customer_id,count(distinct order_date) AS Distinct_visit
from sales group by customer_id;
-- 3. First item purchased by each customer
-- 3. First item purchased by each customer
with firstpurchased AS
(select* ,ROW_NUMBER() over(partition by customer_id order by order_date)  as occurance from sales)
select customer_Id,product_id,order_date
from firstpurchased where occurance=1;
-- 4. Most purchased item and count
select product_id,count(product_id) AS product_count
from sales group by product_id 
order by product_count desc
limit 1;
-- 5. Most popular item per customer
with popular_item as (
	select c.customer_Id,count(m.product_id) as itemCount,m.product_name ,ROW_NUMBER() OVER(partition by customer_id 
	ORDER BY COUNT(m.product_id)desc)as product_rank 
	from sales c join menu m
	on m.product_id = c.product_id
	group by c.customer_id,m.product_id,m.product_name
)
select product_name,customer_id,itemCount from popular_item where product_rank=1;
-- 6. First item after becoming a member
with item_before AS(
select s.customer_id,s.product_id,m.product_name,s.order_date,
	Row_Number() over(partition by s.customer_id order by s.order_date) AS occurance
	from sales s  join menu m  on s.product_id=m.product_id
join members c on s.customer_id=c.customer_id
where s.order_date>=c.join_date
group by s.customer_id,s.product_id,s.order_date,m.product_name
	)
select product_id,product_name,order_date from item_before;

-- 7. Last item before becoming a member
with last_item AS (
	select  s.customer_id,s.product_id,m.product_name,s.order_date ,
	ROW_NUMBER () OVER (partition by s.customer_id order by s.order_date desc ) AS 'occurance'
	from sales s 
	join menu m on s.product_id=m.product_id
	join members c on s.customer_id=c.customer_id
	where s.order_date <=c.join_date
	group by s.customer_id,s.product_id,s.order_date,m.product_name
)
select order_date,product_id,product_name from last_item where occurance=1; 
-- 8. Items and amount before becoming a member
with member_cte AS(
select  s.customer_id,s.product_id,m.product_name,s.order_date,m.price,
	ROW_NUMBER () OVER (partition by s.customer_id order by s.order_date desc ) AS 'occurance'
	from sales s 
	join menu m on s.product_id=m.product_id
	join members c on s.customer_id=c.customer_id
	where s.order_date <= c.join_date
	)
select customer_id,product_id,product_name,price,order_date from member_cte ;
-- 9. Loyalty points: 2x for biryani, 1x for others
select s.customer_id,sum(case when m.product_name='biryani' then 2
else 1
end) AS loyalty from sales s join menu m on s.product_id=m.product_id
group by s.customer_id;
-- 10. Points during first 7 days after joining

-- 11. Total spent on biryani
with spend AS
(select m.product_name,sum(m.price) AS total_spend from menu m
join sales s on m.product_id=s.product_id
where product_name='biryani'
group by product_name
)
select product_name,total_spend from spend;
-- 12. Customer with most dosai orders
with dosai_order AS (
select c.customer_id,s.product_id,m.product_name from sales s
join menu m on s.product_id=m.product_id
join members c on s.customer_id=c.customer_id
where product_name='dosai'
group by m.product_name,c.customer_id,s.product_id
)
select customer_ID,product_id,product_name from dosai_order;

--MSSQL
-- 13. Average spend per visit
WITH SpendVisit AS (
SELECT s.customer_id, s.order_date, SUM(m.price) as TotalSpent FROM
sales s JOIN
menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, s.order_date
)
SELECT customer_id, AVG(TotalSpent) as AverageSpent
FROM SpendVisit
GROUP BY customer_id;

-- 14. Day with most orders in Jan 2025
SELECT TOP 1 FORMAT(order_date, 'dd MMM') AS DayMonth, COUNT(*) as OrderCount FROM sales
WHERE  YEAR(order_date) = 2025 AND MONTH(order_date)=1
GROUP BY order_date
ORDER BY OrderCount DESC;

-- 15. Customer who spent the least
SELECT TOP 1 s.customer_id,
SUM(m.price) AS TotalSpent
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY TotalSpent;

-- 16. Date with most money spent
SELECT TOP 1 s.order_date,
SUM(m.price) AS TotalSpent
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.order_date
ORDER BY TotalSpent DESC;

-- 17. Customers with multiple orders on same day
SELECT s.customer_id,s.order_date,
COUNT(*) AS NumberofOrders
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, s.order_date
HAVING COUNT(*)>1;

-- 18. Visits after membership
SELECT s.customer_id, COUNT(*) AS TotalVisits
FROM sales s JOIN members m
ON s.customer_id = m.customer_id
WHERE s.order_date > m.join_date
GROUP BY s.customer_id;

-- 19. Items never ordered
SELECT m.product_id, m.product_name AS item_never_ordered
FROM menu m LEFT JOIN sales s
ON s.product_id = m.product_id
WHERE s.product_id IS NULL;

-- 20. Customers who ordered but never joined
SELECT DISTINCT s.customer_id AS CustomerNeverJoined
FROM sales s LEFT JOIN members m
ON s.customer_id = m.customer_id
WHERE m.customer_id IS NULL;

--OR

SELECT DISTINCT customer_id FROM sales WHERE customer_id
NOT IN(SELECT customer_id FROM members);
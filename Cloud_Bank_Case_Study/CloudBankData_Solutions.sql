
--Cloud Bank Case Study Questions

--A. Customer Node Exploration
--1.How many unique nodes exist within the Cloud Bank system?
select count(distinct node_id) AS Unique_nodes from cloud_bank.customer_nodes; 
--2.What is the distribution of nodes across different regions?
select region_id,
count(node_id)  from cloud_bank.customer_nodes
group by region_id order by region_id ;
--3.How many customers are allocated to each region?
with each_region As(
select cc.region_id,cr.region_name,cc.customer_id,
count(cc.customer_id) over(partition by cr.region_id) AS total
from cloud_bank.regions  as cr
	join  cloud_bank.customer_nodes as cc
	on cr.region_id=cc.region_id
	
)
select region_id,region_name,total from each_region ;
------------
select cr.region_id,cr.region_name,
count(distinct cc.customer_id) from cloud_bank.regions as cr  join cloud_bank.customer_nodes as cc
on cr.region_id=cc.region_id
group by cr.region_id
order by cr.region_id

--4.On average, how many days does a customer stay on a node before being reallocated?
select node_id,avg(end_date-start_date) from cloud_bank.customer_nodes
where end_date !='9999-12-31'
 group by node_id;

--5.What are the median, 80th percentile, and 95th percentile reallocation durations (in days) for customers in each region?
-- over(partition by region_id order by customer_id) AS median

select * from cloud_bank.regions ;
select * from  cloud_bank.customer_nodes;
select * from customer_transactions;
SELECT
    region_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (end_date - start_date)) AS median_duration,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY (end_date - start_date)) AS p80th,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY (end_date - start_date)) AS p90th
FROM
    cloud_bank.customer_nodes
WHERE start_date IS NOT NULL AND end_date IS NOT NULL
GROUP BY region_id
ORDER BY region_id;



--B. Customer Transactions

--1 What are the unique counts and total amounts for each transaction type (e.g., deposit, withdrawal, purchase)?
select txn_type,count( distinct customer_id) As unique_count ,sum(txn_amount)AS total_amount 
from customer_transactions
group by txn_type;
---
select txn_type,count(  txn_Type) As unique_count ,sum(txn_amount)AS total_amount 
from customer_transactions
group by txn_type;
--2. What is the average number of historical deposits per customer, along with the average total deposit amount?
with average_number AS(
select customer_id,
	avg(txn_Amount) over() AS average,
	avg(txn_Amount) over(partition by customer_id) AS per_customer_average from customer_transactions where txn_type='deposit'
	
)
select customer_id,ROUND(average,2),ROUND(per_customer_average,2) from average_number;
--3.For each month, how many Cloud Bank customers made more than one deposit and either one purchase or one withdrawal?
with Each_month AS(
	select customer_Id,    EXTRACT(MONTH FROM txn_date) AS month,
        COUNT(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit_count,
        COUNT(CASE WHEN txn_type = 'purchase' THEN 1 END) AS purchase_count,
        COUNT(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count
  from customer_transactions group by customer_id,extract (month from txn_date)
	)
select month,
    COUNT(DISTINCT customer_id) AS total_customers from Each_month
where deposit_count>1 And purchase_count + withdrawal_count=1
group by month
order by month;

--4.What is the closing balance for each customer at the end of every month?
--closing_balance=purchase-deposit/-withdrawal
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as Month,
sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by month,customer_id
	order by customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
)
select* from c2;

--5 .What percentage of customers increased their closing balance by more than 5% month-over-month?
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as Month,
sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by TO_CHAR(txn_date,'YYYY-MM'),customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
),
-- select* from c2;
c3 as(
select customer_id,Month,closing,lag(closing) over(partition by customer_id order by month)as pre_balance from c2
),
 --select * from c3
c4 as(
select customer_id,Month,closing,pre_balance, count(month) over(partition by customer_id) as total,
		
	   CASE WHEN pre_balance >0 then ((closing-pre_balance)/pre_balance)*100
       ELSE null
		end as final_balance
		from c3
	
 ), 
 --select* from c4;
c5 as(
-- select customer_id,final_balance, count(final_balance) over(partition by customer_id) as total from c4 where final_balance is not null
    SELECT DISTINCT customer_id  FROM c4 group by customer_id having min(final_balance) > 5
) ,
--select * from c5;

c6 as(
select count(distinct customer_id) as counts from  customer_transactions
)-- select * from c5;

SELECT 
    ROUND((COUNT(DISTINCT c5.customer_id)::DECIMAL / c6.counts) * 100, 2) AS percentage
FROM 
    c5, c6 group by  c6.counts;
	select (total_grow/counts)*100 as percent from c5,c6

--C. Cloud Storage Allocation Challenge
--The Cloud Bank team is experimenting with three storage allocation strategies:

Option 1: Storage is provisioned based on the account balance at the end of the previous month

Option 2: Storage is based on the average daily balance over the previous 30 days

Option 3: Storage is updated in real-time, reflecting the balance after every transaction

To support this analysis, generate the following:

--1.A running balance for each customer that accounts for all transaction activity
	select customer_id,txn_date,txn_type,
	sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) over(partition by customer_id order by txn_date 
	rows between unbounded preceding and current row 
	)AS running_balance
 from customer_transactions
group by customer_id,txn_date,txn_amount,txn_type
 order by customer_id,txn_Date

--2.The end-of-month balance for every customer
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as month,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by TO_CHAR(txn_date,'YYYY-MM'),customer_id
	order by customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
)
select* from c2;
--3.The minimum, average, and maximum running balances per customer

WITH running_balance AS (
 select customer_id,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) 
	OVER (
      PARTITION BY  customer_id ORDER BY txn_date) AS balance
  FROM customer_transactions
)

SELECT customer_id,
  MIN(balance) AS min_balance,
  MAX(balance) AS max_balance,
  ROUND(AVG(balance), 2) AS avg_balance FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;

--4.Using this data, estimate how much cloud storage would have been required for each allocation option on a monthly basis.
--The Cloud Bank team is experimenting with three storage allocation strategies:
-- Option 1: Storage is provisioned based on the account balance at the end of the previous month
-- Option 2: Storage is based on the average daily balance over the previous 30 days
-- Option 3: Storage is updated in real-time, reflecting the balance after every transaction

WITH running_balance AS (
 select customer_id,TO_CHAR(txn_date,'YYYY-MM')as month,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end) OVER (PARTITION BY  customer_id ORDER BY txn_date) AS balance FROM customer_transactions
)
SELECT customer_id,month,
  MAX(balance) AS max_balance FROM running_balance
	GROUP BY customer_id,month
	ORDER BY customer_id;
select * from customer_transactions order by customer_id
select customer_id,month,option_1,option_2,option_3


WITH RECURSIVE forward AS (
  -- Anchor member: month 1 data
  SELECT 
    customer_id, 
    DATE_TRUNC('month', txn_date)::date AS month,
    txn_amount,
    txn_amount AS forward_balance,
    SUM(CASE 
          WHEN txn_type = 'deposit' THEN txn_amount
          WHEN txn_type IN ('purchase', 'withdrawal') THEN -txn_amount
        END) OVER (
          PARTITION BY customer_id 
          ORDER BY txn_date
        ) AS balance
  FROM customer_transactions
  WHERE EXTRACT(month FROM txn_date) = 1

  UNION ALL

  -- Recursive member: process next months
  SELECT 
    ct.customer_id,
    DATE_TRUNC('month', ct.txn_date)::date AS month,
    ct.txn_amount,
    CASE 
      WHEN ct.txn_amount IS NOT NULL THEN ct.txn_amount
      ELSE f.forward_balance
    END AS forward_balance,
    f.balance  -- Carry forward the previous balance
  FROM customer_transactions ct
  JOIN forward f 
    ON ct.customer_id = f.customer_id
   AND EXTRACT(month FROM ct.txn_date) = EXTRACT(month FROM f.month) + 1
)
SELECT * FROM forward
ORDER BY customer_id, month;



-- Step 1: Find the date range (min and max month in your table)
WITH date_range AS (
    SELECT 
        MIN(txn_date, 'YYYY-MM')AS start_date,
        MAX(txn_date, 'YYYY-MM') AS end_date
    FROM customer_transactions
),

-- Step 2: Generate all first-of-the-month dates between the range
months AS (
    SELECT generate_series(
        (SELECT start_date FROM date_range),
        (SELECT end_date FROM date_range),
        INTERVAL '1 month'
    )::date AS txn_date
),

-- Step 3: Get all unique customers
customers AS (
    SELECT DISTINCT customer_id FROM customer_transactions
),

-- Step 4: Cross join to get customer-month combinations
customer_months AS (
    SELECT c.customer_id, m.txn_date
    FROM customers c
    CROSS JOIN months m
)

-- Step 5: Final join with your actual table
SELECT 
    cm.customer_id, 
    cm.txn_date,
    t.closing_balance, 
    t.closing
FROM customer_months cm
LEFT JOIN your_table t
    ON cm.customer_id = t.customer_id 
    AND (t.month, 'YYYY-MM') = cm.txn_date
ORDER BY cm.customer_id, cm.txn_date;


-- D. Advanced Challenge: Interest-Based Data Growth
-- Cloud Bank wants to test a more complex data allocation method:
--applying an interest-based growth model similar to traditional savings accounts.

-- If the annual interest rate is 6%, how much additional cloud storage would customers receive if:

-- Interest is calculated daily, without compounding?

-- (Optional Bonus) Interest is calculated daily with compounding?









--Cloud Bank Case Study Questions

--A. Customer Node Exploration
--1.How many unique nodes exist within the Cloud Bank system?
select count(distinct node_id) AS Unique_nodes from cloud_bank.customer_nodes; 
--2.What is the distribution of nodes across different regions?
select region_id,
count(node_id)  from cloud_bank.customer_nodes
group by region_id order by region_id ;
--3.How many customers are allocated to each region?
with each_region As(
select cc.region_id,cr.region_name,cc.customer_id,
count(cc.customer_id) over(partition by cr.region_id) AS total
from cloud_bank.regions  as cr
	join  cloud_bank.customer_nodes as cc
	on cr.region_id=cc.region_id
	
)
select region_id,region_name,total from each_region ;
------------
select cr.region_id,cr.region_name,
count(distinct cc.customer_id) from cloud_bank.regions as cr  join cloud_bank.customer_nodes as cc
on cr.region_id=cc.region_id
group by cr.region_id
order by cr.region_id

--4.On average, how many days does a customer stay on a node before being reallocated?
select node_id,avg(end_date-start_date) from cloud_bank.customer_nodes
where end_date !='9999-12-31'
 group by node_id;

--5.What are the median, 80th percentile, and 95th percentile reallocation durations (in days) for customers in each region?
-- over(partition by region_id order by customer_id) AS median

select * from cloud_bank.regions ;
select * from  cloud_bank.customer_nodes;
select * from customer_transactions;
SELECT
    region_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (end_date - start_date)) AS median_duration,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY (end_date - start_date)) AS p80th,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY (end_date - start_date)) AS p90th
FROM
    cloud_bank.customer_nodes
WHERE start_date IS NOT NULL AND end_date IS NOT NULL
GROUP BY region_id
ORDER BY region_id;



--B. Customer Transactions

--1 What are the unique counts and total amounts for each transaction type (e.g., deposit, withdrawal, purchase)?
select txn_type,count( distinct customer_id) As unique_count ,sum(txn_amount)AS total_amount 
from customer_transactions
group by txn_type;
---
select txn_type,count(  txn_Type) As unique_count ,sum(txn_amount)AS total_amount 
from customer_transactions
group by txn_type;
--2. What is the average number of historical deposits per customer, along with the average total deposit amount?
with average_number AS(
select customer_id,
	avg(txn_Amount) over() AS average,
	avg(txn_Amount) over(partition by customer_id) AS per_customer_average from customer_transactions where txn_type='deposit'
	
)
select customer_id,ROUND(average,2),ROUND(per_customer_average,2) from average_number;
--3.For each month, how many Cloud Bank customers made more than one deposit and either one purchase or one withdrawal?
with Each_month AS(
	select customer_Id,    EXTRACT(MONTH FROM txn_date) AS month,
        COUNT(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit_count,
        COUNT(CASE WHEN txn_type = 'purchase' THEN 1 END) AS purchase_count,
        COUNT(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count
  from customer_transactions group by customer_id,extract (month from txn_date)
	)
select month,
    COUNT(DISTINCT customer_id) AS total_customers from Each_month
where deposit_count>1 And purchase_count + withdrawal_count=1
group by month
order by month;

--4.What is the closing balance for each customer at the end of every month?
--closing_balance=purchase-deposit/-withdrawal
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as Month,
sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by month,customer_id
	order by customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
)
select* from c2;

--5 .What percentage of customers increased their closing balance by more than 5% month-over-month?
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as Month,
sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by TO_CHAR(txn_date,'YYYY-MM'),customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
),
-- select* from c2;
c3 as(
select customer_id,Month,closing,lag(closing) over(partition by customer_id order by month)as pre_balance from c2
),
 --select * from c3
c4 as(
select customer_id,Month,closing,pre_balance, count(month) over(partition by customer_id) as total,
		
	   CASE WHEN pre_balance >0 then ((closing-pre_balance)/pre_balance)*100
       ELSE null
		end as final_balance
		from c3
	
 ), 
 --select* from c4;
c5 as(
-- select customer_id,final_balance, count(final_balance) over(partition by customer_id) as total from c4 where final_balance is not null
    SELECT DISTINCT customer_id  FROM c4 group by customer_id having min(final_balance) > 5
) ,
--select * from c5;

c6 as(
select count(distinct customer_id) as counts from  customer_transactions
)-- select * from c5;

SELECT 
    ROUND((COUNT(DISTINCT c5.customer_id)::DECIMAL / c6.counts) * 100, 2) AS percentage
FROM 
    c5, c6 group by  c6.counts;
	select (total_grow/counts)*100 as percent from c5,c6

--C. Cloud Storage Allocation Challenge
--The Cloud Bank team is experimenting with three storage allocation strategies:

Option 1: Storage is provisioned based on the account balance at the end of the previous month

Option 2: Storage is based on the average daily balance over the previous 30 days

Option 3: Storage is updated in real-time, reflecting the balance after every transaction

To support this analysis, generate the following:

--1.A running balance for each customer that accounts for all transaction activity
	select customer_id,txn_date,txn_type,
	sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) over(partition by customer_id order by txn_date 
	rows between unbounded preceding and current row 
	)AS running_balance
 from customer_transactions
group by customer_id,txn_date,txn_amount,txn_type
 order by customer_id,txn_Date

--2.The end-of-month balance for every customer
with cte1 as(
select customer_id,TO_CHAR(txn_date,'YYYY-MM') as month,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) as closing_balance
	from customer_transactions
	group by TO_CHAR(txn_date,'YYYY-MM'),customer_id
	order by customer_id
	),
c2 as(
select customer_id,Month,closing_balance,sum(closing_balance)
over(partition by customer_id  order by month rows between unbounded preceding and current row ) as closing
from cte1
)
select* from c2;
--3.The minimum, average, and maximum running balances per customer

WITH running_balance AS (
 select customer_id,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end
	) 
	OVER (
      PARTITION BY  customer_id ORDER BY txn_date) AS balance
  FROM customer_transactions
)

SELECT customer_id,
  MIN(balance) AS min_balance,
  MAX(balance) AS max_balance,
  ROUND(AVG(balance), 2) AS avg_balance FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;

--4.Using this data, estimate how much cloud storage would have been required for each allocation option on a monthly basis.
--The Cloud Bank team is experimenting with three storage allocation strategies:
-- Option 1: Storage is provisioned based on the account balance at the end of the previous month
-- Option 2: Storage is based on the average daily balance over the previous 30 days
-- Option 3: Storage is updated in real-time, reflecting the balance after every transaction

WITH running_balance AS (
 select customer_id,TO_CHAR(txn_date,'YYYY-MM')as month,sum(case
	when txn_type='deposit' then txn_amount
	when txn_Type in ('purchase','withdrawal') then -txn_Amount
	end) OVER (PARTITION BY  customer_id ORDER BY txn_date) AS balance FROM customer_transactions
)
SELECT customer_id,month,
  MAX(balance) AS max_balance FROM running_balance
	GROUP BY customer_id,month
	ORDER BY customer_id;
select * from customer_transactions order by customer_id
select customer_id,month,option_1,option_2,option_3


WITH RECURSIVE forward AS (
  -- Anchor member: month 1 data
  SELECT 
    customer_id, 
    DATE_TRUNC('month', txn_date)::date AS month,
    txn_amount,
    txn_amount AS forward_balance,
    SUM(CASE 
          WHEN txn_type = 'deposit' THEN txn_amount
          WHEN txn_type IN ('purchase', 'withdrawal') THEN -txn_amount
        END) OVER (
          PARTITION BY customer_id 
          ORDER BY txn_date
        ) AS balance
  FROM customer_transactions
  WHERE EXTRACT(month FROM txn_date) = 1

  UNION ALL

  -- Recursive member: process next months
  SELECT 
    ct.customer_id,
    DATE_TRUNC('month', ct.txn_date)::date AS month,
    ct.txn_amount,
    CASE 
      WHEN ct.txn_amount IS NOT NULL THEN ct.txn_amount
      ELSE f.forward_balance
    END AS forward_balance,
    f.balance  -- Carry forward the previous balance
  FROM customer_transactions ct
  JOIN forward f 
    ON ct.customer_id = f.customer_id
   AND EXTRACT(month FROM ct.txn_date) = EXTRACT(month FROM f.month) + 1
)
SELECT * FROM forward
ORDER BY customer_id, month;



-- Step 1: Find the date range (min and max month in your table)
WITH date_range AS (
    SELECT 
        MIN(txn_date, 'YYYY-MM')AS start_date,
        MAX(txn_date, 'YYYY-MM') AS end_date
    FROM customer_transactions
),

-- Step 2: Generate all first-of-the-month dates between the range
months AS (
    SELECT generate_series(
        (SELECT start_date FROM date_range),
        (SELECT end_date FROM date_range),
        INTERVAL '1 month'
    )::date AS txn_date
),

-- Step 3: Get all unique customers
customers AS (
    SELECT DISTINCT customer_id FROM customer_transactions
),

-- Step 4: Cross join to get customer-month combinations
customer_months AS (
    SELECT c.customer_id, m.txn_date
    FROM customers c
    CROSS JOIN months m
)

-- Step 5: Final join with your actual table
SELECT 
    cm.customer_id, 
    cm.txn_date,
    t.closing_balance, 
    t.closing
FROM customer_months cm
LEFT JOIN your_table t
    ON cm.customer_id = t.customer_id 
    AND (t.month, 'YYYY-MM') = cm.txn_date
ORDER BY cm.customer_id, cm.txn_date;


-- D. Advanced Challenge: Interest-Based Data Growth
-- Cloud Bank wants to test a more complex data allocation method:
--applying an interest-based growth model similar to traditional savings accounts.

-- If the annual interest rate is 6%, how much additional cloud storage would customers receive if:

-- Interest is calculated daily, without compounding?

-- (Optional Bonus) Interest is calculated daily with compounding?





























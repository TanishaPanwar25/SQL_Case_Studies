
---------------------------------------------------------------------------------

## Question and Solution
## 📈 A. High Level Sales Analysis

select  distinct prod_id from sales;
--**1. What was the total quantity sold for all products?**
select  prod_id,count(qty)total_quantity from sales
	group by prod_id

--**2. What is the total generated revenue for all products before discounts?**
select prod_id,sum(price*qty) as total_price from sales
	where discount=0
	group by prod_id

select sum(price*qty) as total_price from sales

--**3. What was the total discount amount for all products?**
select sum(price*qty) as total_price,sum(discount) as total_discount from sales
	group by prod_id
--## 🧾 B. Transaction Analysis

--**1. How many unique transactions were there?**
with c1 as(
select txn_id,count(txn_id) total_count from sales
	group by txn_id
	having count(txn_id)=1
	)
	--select count(txn_id) as total_unique_transactions from c1;
	select txn_id as total_unique_transactions from c1;
	
--**2. What is the average unique products purchased in each transaction?**
select avg(pro_count) as average_unique_product
	from (select txn_id,count(distinct prod_id)as pro_count from sales 
		group by txn_id)as sub;

--**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**
with c1 as(
select txn_id,sum((qty*price-discount))over(partition by txn_id) as price from sales
)
select txn_id,
  percentile_cont(0.25) within group(order by price) over () as percentile_cont_25,
  percentile_cont(0.50) within group(order by price) over () as percentile_cont_50,
  percentile_cont(0.75) within group(order by price) over () as percentile_cont_75
  from c1 
  group by txn_id,price
  order by txn_id



--**4. What is the average discount value per transaction?**
select txn_id,avg(discount) as price from sales
group by txn_id

--**5. What is the percentage split of all transactions for members vs non-members?**
with cte as(

	select count(member) total from sales
),
c1 as (
	select count(member)total_member from sales where member=1
),
c2 as(
	select count(member)total_non_member from sales where member=0
)
select ROUND(CAST( total_member as float)/cast (total as float)*100,2) members,
		ROUND(CAST(total_non_member as float )/cast (total as float)*100,2)non_member from cte,c1,c2
--**6. What is the average revenue for member transactions and non-member transactions?**
with cte as(
	select count(member) total from sales
),
c1 as (
	select avg((price*qty)-discount)avg_member from sales where member=1
),
c2 as(
	select avg((price*qty)-discount)avg_non_member from sales where member=0
	)
select avg_member,avg_non_member from c1,c2

--## 👚 C. Product Analysis

--**1. What are the top 3 products by total revenue before discount?**
select top 3 prod_id,product_name,sum(s.price*qty)as total_revenue from sales s
join product_details p on 
s.prod_id=p.product_id
where discount=0
group by prod_id,product_name
order by total_revenue desc
--**2. What is the total quantity, revenue and discount for each segment?**
select segment_name,
	sum(qty)as total_quantity,
	sum(discount)as total_discount,
	sum((s.price*qty)-discount) as total_revenue
	from sales s
	join product_details p on 
	s.prod_id=p.product_id
	group by segment_name;
--**3. What is the top selling product for each segment?**
with c1 as(
select segment_name,prod_id,product_name,sum(qty)total_qty
	from sales s
	join product_details p on 
	s.prod_id=p.product_id
	group by segment_name,prod_id,product_name
	),
	c2 as(
	select segment_name,prod_id,product_name,total_qty,rank()
	over(partition by segment_name order by total_qty desc) rn from c1
	)
	select  * from c2 where rn=1
--**4. What is the total quantity, revenue and discount for each category?**
select category_name,
	sum(qty)as total_quantity,
	sum(discount)as total_discount,
	sum((s.price*qty)-discount) as total_revenue
	from sales s
	join product_details p on 
	s.prod_id=p.product_id
	group by category_name;
--**5. What is the top selling product for each category?**
with c1 as(
select category_name,prod_id,product_name,sum(qty)total_qty
	from sales s
	join product_details p on 
	s.prod_id=p.product_id
	group by category_name,prod_id,product_name
	),
	c2 as(
	select category_name,prod_id,product_name,total_qty,rank()
	over(partition by category_name order by total_qty desc) rn from c1
	)
	select  * from c2 where rn=1
--**6. What is the percentage split of revenue by product for each segment?**
with cte as(
	select segment_id,segment_name,product_name,sum(s.price*qty)as revenue 
	from product_details p join sales s
	on p.product_id=s.prod_id
	group by segment_name,product_name,segment_id
),
c2 as(
	select segment_name, sum(revenue) as total from cte
	group by segment_name
)
--select * from c2
select segment_id,c2.segment_name,product_name,
round(100*cast(revenue as float)/cast(total as  Indigo Rain Jacket - Womensfloat),2) as percentage_split from cte c1 join c2
on c1.segment_name=c2.segment_name
--**7. What is the percentage split of revenue by segment for each category?**
with cte as(
	select segment_id,segment_name,category_name,sum(s.price*qty)as revenue 
	from product_details p join sales s
	on p.product_id=s.prod_id
	group by segment_name,category_name,segment_id
),
c2 as(
	select category_name, sum(revenue) as total from cte
	group by category_name
)
--select * from c2
select segment_id,segment_name,c2.category_name,
round(100*cast(revenue as float)/cast(total as float),2) as percentage_split from cte c1 join c2
on c1.category_name=c2.category_name

--**8. What is the percentage split of total revenue by category?**
with cte as(
	select sum(price*qty)as revenue 
	from sales
	
),
c2 as(
	select category_name, sum(s.price*qty) as total from 
	sales s join product_details p on p.product_id=s.prod_id
	group by category_name
)
--select * from c2
select c2.category_name,
round(100*cast(total as float)/cast(revenue as float),2) as percentage_split from cte c1 , c2
--**9. What is the total transaction “penetration” for each product?
--(select hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**
with c1 as(
select prod_id,product_name,count(txn_id)as total_transactions from sales s 
join product_details p on p.product_id=s.prod_id 
where qty>=1
group by product_name,prod_id
),
c2 as(
select count(txn_id)as total from sales
)
select round(100*cast(total_transactions as float)/cast(total as float),2) from c1,c2

--**10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**
with c1 as(
select txn_id,prod_id, count(prod_id) over(partition by txn_id order by txn_id)T_Pro from  sales
)
select distinct prod_id,txn_id from c1 
where T_Pro>=3

select * from sales;
## 📝 Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the QT team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also QT) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

***

## 💡 Bonus Challenge

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

***

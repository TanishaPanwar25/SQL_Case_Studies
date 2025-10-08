
create database Consumer;

drop  table dbo.consumer_Behavior;
--update column
select * from dbo.Consumer_Behavior_Analysis;
update dbo.Consumer_Behavior_Analysis
	set Purchase_Amount=REPLACE(Purchase_Amount,'$','')

Alter table dbo.Consumer_Behavior_Analysis
alter column Purchase_Amount Decimal(10,2);

--change datatype
Alter table dbo.Consumer_Behavior_Analysis
alter column Customer_Satisfaction Int;

Alter table dbo.consumer_Behavior_Analysis
alter column Return_Rate Int;
--  price column update ?
select * from dbo.consumer_Behavior_Analysis;
--LEVEL 1 — Basic SELECT, WHERE & ORDER BY
--• Retrieve all details of customers who are married and have a high income level.
select * from dbo.consumer_Behavior_Analysis
where Marital_Status = 'married' and Income_level='High';

-- List all customers who made purchases through Online channel and used a credit card.
select Customer_Id,Purchase_Channel,Payment_Method from dbo.consumer_Behavior_Analysis
where Purchase_Channel='Online' and Payment_Method='Credit Card';

--• Show customers who spent more than $500 in a single purchase.
select count(distinct Customer_ID) from dbo.Consumer_Behavior_Analysis;
--select customer_Id,Purchase_Amount from dbo.consumer_Behavior_Analysis
--where CAST(REPLACE(Purchase_Amount, '$' , '') AS decimal) > 400
  --$500> GRATER RECORD NOT AVALABLE

select customer_Id,Purchase_Amount from dbo.consumer_Behavior_Analysis
where Purchase_Amount>400;

--• Display Customer_ID, Age, Gender, and Purchase_Category sorted by Age descending.
SELECT 
	Customer_ID,Age,Gender,Purchase_Category
	from dbo.Consumer_Behavior_Analysis
	order by Age desc;

--• Retrieve customers whose Discount_Used is TRUE but Discount_Sensitivity = ‘Not Sensitive’.
select
	Customer_Id,Age,Gender,Discount_Used, Discount_Sensitivity
	from dbo.Consumer_Behavior_Analysis
	where Discount_Used='True' and Discount_Sensitivity='Not Sensitive';

--• Get customers who are members of loyalty program and have a Customer_Satisfaction>= 8.
select 
	customer_id,customer_loyalty_program_member,Customer_Satisfaction
	from dbo.Consumer_Behavior_Analysis
	where Customer_Satisfaction>=8 and Customer_Loyalty_Program_Member = 'True';

--• Find all customers from 'Food & Beverages' or 'Clothing' category.
select Customer_ID,Purchase_Category
	from dbo.Consumer_Behavior_Analysis
	--where Purchase_Category='Food & Beverages' or Purchase_Category='Clothing'
	where Purchase_Category in ('Food & Beverages' ,'Clothing')
	order by Purchase_Category;

--• Show customers who did not use discounts and purchased via In-Store.
select Customer_ID,Discount_Used, Purchase_Channel 
	from dbo.Consumer_Behavior_Analysis
	where Purchase_Channel='In-Store' and Discount_Used = 'False';

--• List all customers with Purchase_Intent = 'Impulsive'.
select Customer_ID,Purchase_Intent
	from dbo.Consumer_Behavior_Analysis
	where Purchase_Intent='Impulsive';
--• Retrieve distinct Payment_Methods used by customers.
select distinct Payment_Method
	from dbo.Consumer_Behavior_Analysis;

------------------------------------------------------------------------------------------
--LEVEL 2 — Aggregations (COUNT, SUM, AVG, GROUP BY)

--• Find the average purchase amount for each Purchase_Category.
select 
	Purchase_Category,Avg(Purchase_Amount) AS Average_Purchase 
	from dbo.Consumer_Behavior_Analysis
	group by Purchase_Category
	order by Avg(Purchase_Amount) desc;

--• Count how many customers fall into each Income_Level.
select count(Customer_ID)as Customers,Income_Level
	from dbo.Consumer_Behavior_Analysis
	group by Income_Level;

--• Calculate the total revenue generated from each Purchase_Channel.
select 
	purchase_Channel,sum(Purchase_Amount) as Total_Revenue
	from dbo.Consumer_Behavior_Analysis
	group by Purchase_Channel;

-- Determine the average Product_Rating for each Brand_Loyalty level.
select
	Brand_Loyalty,Avg(Product_Rating) as Product_Rating from 
	dbo.Consumer_Behavior_Analysis
	group by Brand_Loyalty;

--• Find average Customer_Satisfaction grouped by Marital_Status.
select 
	Marital_Status,Avg(Customer_Satisfaction) As average_Customer_Satisfaction
	from dbo.Consumer_Behavior_Analysis
	group by Marital_Status;

--• For each Location, count how many purchases were made.
select Location ,count(Payment_Method) Total_Purchase
	from dbo.Consumer_Behavior_Analysis
	group by Location;

-- Show average Time_Spent_on_Product_Research grouped by Education_Level.
select Avg(Time_Spent_on_Product_Research_hours)as average_Time_Spent_on_Product_Research,Education_Level 
	from dbo.Consumer_Behavior_Analysis
	group by Education_Level;

--• Calculate total Purchase_Amount and average Frequency_of_Purchase by Occupation.
select 
	Sum(Purchase_Amount) as Total_Purchase,Avg(Frequency_of_Purchase) As Avg_Freaquency_of_Purchase ,Occupation
	from dbo.Consumer_Behavior_Analysis
	group by Occupation;

--• Find which Device_Used_for_Shopping generates the highest average Purchase_Amount.
select Top 1
	Device_Used_for_Shopping,Avg(Purchase_Amount) as Purchase_Amonut
	from dbo.Consumer_Behavior_Analysis
	group by Device_Used_for_Shopping
	order by Avg(Purchase_Amount) desc;

--• Find average Return_Rate for each Discount_Sensitivity level.
select 
	Discount_Sensitivity ,Avg(Return_Rate)as Average_Return_Rate 
	from dbo.Consumer_Behavior_Analysis
	group by Discount_Sensitivity;

-----------------------------------------------------------------------------------------------------------
--LEVEL 3 — Filtering with Aggregations & Subqueries

--• Find customers who spent more than the average Purchase_Amount overall.
select Customer_ID,Purchase_Amount
	from dbo.Consumer_Behavior_Analysis
	where Purchase_Amount > (select Avg(Purchase_Amount) from dbo.Consumer_Behavior_Analysis) ;

--• Retrieve the top 5 locations with the highest average Customer_Satisfaction.
select top 5 Location,Customer_Satisfaction from dbo.Consumer_Behavior_Analysis
	where Customer_Satisfaction 
	> (select avg(Customer_Satisfaction)Average_Customer_satisfaction
	from dbo.Consumer_Behavior_Analysis )
	order by Customer_Satisfaction desc;
--• Identify the Income_Level with the highest total purchase amount.
select top 1 Income_Level ,Total_Purchsae_amount 
	from (select Income_level,sum(Purchase_Amount) as Total_Purchsae_amount 
	from dbo.Consumer_Behavior_Analysis group by Income_Level)as a
	order by Total_Purchsae_amount desc; 
;
--• Find Purchase_Categories where the average Product_Rating < 3.
select 
	Purchase_Category,Average_Rating 
	from (select Purchase_Category, avg(Product_Rating)as Average_Rating from dbo.Consumer_Behavior_Analysis
		group by Purchase_Category)AS C
	where Average_Rating<3;

--• List customers whose Purchase_Amount is in the top 10% of all purchases.
WITH ranked AS (
    SELECT customer_id,Purchase_Amount,
        PERCENT_RANK() OVER (ORDER BY Purchase_Amount) AS pr FROM dbo.Consumer_Behavior_Analysis
)
SELECT customer_id, Purchase_Amount FROM ranked
WHERE pr >= 0.9;

select distinct gender from dbo.Consumer_Behavior_Analysis
--• Show Education_Level(s) where average Time_to_Decision > 3 days.
select Education_Level,Average_Time_to_Decision from
(select Education_Level, Avg(Time_to_Decision)as Average_Time_to_Decision from dbo.Consumer_Behavior_Analysis
group by Education_Level)as c where Average_Time_to_Decision>3;

--• Retrieve customers with Brand_Loyalty = 5 and Product_Rating >= 4, sorted by Purchase_Amount descending.
select 
	Customer_ID,Brand_Loyalty,Product_Rating,Purchase_Amount
	from dbo.Consumer_Behavior_Analysis
	where Brand_Loyalty = 5 and Product_Rating >=4
	order by Purchase_Amount desc;

--• Find Purchase_Channel that contributes to the highest revenue.
select  Top 1
	Purchase_Channel ,Sum(Purchase_Amount ) as Higest_Revenue
	from dbo.Consumer_Behavior_Analysis
	group by Purchase_Channel
	order by Higest_Revenue desc;

--• Display top 3 Occupations based on total Purchase_Amount.
select top 2 Occupation,Sum(Purchase_Amount)As Total_Purchase from dbo.Consumer_Behavior_Analysis
group by Occupation;

--• Find Gender-wise comparison of average Return_Rate.
select Gender,Avg(Return_rate)as Average_Return_Rate
	from dbo.Consumer_Behavior_Analysis
	group by Gender;
	
--LEVEL 4 — Date, String & Conditional Logic
select * from dbo.Consumer_Behavior_Analysis;
--• Find the month with the highest total Purchase_Amount.
select DATEPART(MONTH, Time_of_Purchase)as Month, sum(Purchase_Amount) as Total_Revenue
from dbo.Consumer_Behavior_Analysis
group by DATEPART(MONTH, Time_of_Purchase)
order by DATEPART(MONTH, Time_of_Purchase)

-- Extract day of week from Time_of_Purchase and find which day sees most purchases.
select 
	DATEPART(WEEKDAY,Time_of_Purchase)as WeekDay,sum(Purchase_Amount) as total_Revenue
	from dbo.Consumer_Behavior_Analysis
	group by DATEPART(WEEKDAY,Time_of_Purchase)
	order by total_Revenue desc;

--• Calculate average Purchase_Amount for purchases made using a discount vs without discount.
select Discount_Used,avg(Purchase_Amount)
	from dbo.Consumer_Behavior_Analysis
	group by Discount_Used;

--• Show customers who made purchases in 2024 Q1 (Jan–Mar).
select Customer_id,Time_of_Purchase from Consumer_Behavior_Analysis
where YEAR(Time_of_Purchase)=2024 and  DATEPART(QUARTER, Time_of_Purchase)=1;

--• Display Age groups (<25, 25–40, >40) and their average Purchase_Amount.
select 
	Avg(case when Age<25 then Purchase_Amount End)AS less_than_25_Age_Purchase_Amount,
	Avg(case when Age<25 then Purchase_Amount End)AS between_25_40_Age_Purchase_Amount,
	Avg(case when Age<25 then Purchase_Amount End)As less_than_40_Age_Purchase_Amount
	from dbo.Consumer_Behavior_Analysis;

-- Count how many purchases were made using PayPal vs Credit Card.
select
	count(Customer_id)as total_purchase ,Payment_Method from dbo.Consumer_Behavior_Analysis
	where Payment_Method in ('PayPal','Credit Card')
	group by Payment_Method;

--• Find customers whose Purchase_Intent = 'Planned' but Discount_Used = TRUE.
select Customer_ID,Purchase_Intent,Discount_Used
	from dbo.Consumer_Behavior_Analysis
	where Purchase_Intent='Planned' and Discount_Used='True';

--• Create a derived column 'Purchase_Type' (Discounted vs Full Price) and group by Purchase_Type to get total sales.
select 
	case when Discount_Used = 'True' then 'Discounted' else 'Full Price' end as Purchase_type,
	sum(Purchase_Amount)as total_Sales
	 from dbo.Consumer_Behavior_Analysis
	 group by case when Discount_Used = 'True' then 'Discounted' Else 'Full Price' end ;

--• Find average Time_to_Decision for each Purchase_Intent.
select Purchase_Intent,avg(Time_to_Decision)Average_Time_to_Decision from dbo.Consumer_Behavior_Analysis
group by Purchase_Intent;

--• Determine percentage of customers who are Loyalty Program Members.
select count(*)as total_Customer,
		sum(case when Customer_Loyalty_Program_Member='True' then 1 else 0 End) as Member,
		sum(case when Customer_Loyalty_Program_Member='False' then 1 else 0 End) as not_member,
		round(sum(case when Customer_Loyalty_Program_Member='True' then 1 else 0 End)*100 /count(*),2) as Member_percentage
		from dbo.Consumer_Behavior_Analysis;

--LEVEL 5 — Window Functions & Analytical Insights

--• Rank customers by Purchase_Amount within each Purchase_Category.
select
	customer_id,Purchase_Category,Purchase_Amount ,
	rank()over(partition by Purchase_Category order by Purchase_Amount desc)as Rank
	from dbo.Consumer_Behavior_Analysis;

--• Find cumulative Purchase_Amount by Location ordered by Purchase_Amount.
select Location,Purchase_Amount,
	CUME_DIST()over(partition by Location order by Purchase_Amount)as Cumulative_Purchase_Amount
	from dbo.Consumer_Behavior_Analysis;

--• For each Occupation, find average Purchase_Amount and show how each customer compares to the average.
select Occupation,Customer_ID,avg(Purchase_Amount) over( partition by Occupation)as average_Purchase_Amount,
	Purchase_Amount,(Purchase_Amount-Avg(Purchase_Amount)over( partition by Occupation))as Diffrence
	from dbo.Consumer_Behavior_Analysis
	order by Occupation;

--• Show running total of Purchase_Amount by Time_of_Purchase.
select 
	Purchase_Amount,Time_of_Purchase,sum(Purchase_Amount)over(partition by Time_of_Purchase)as Running_Total
	from dbo.Consumer_Behavior_Analysis;

--• Calculate percentile rank of customers based on Brand_Loyalty.
select
	customer_id,Brand_Loyalty,
	PERCENT_RANK() over(order by Brand_Loyalty desc)
	from dbo.Consumer_Behavior_Analysis;

--• For each Income_Level, show the top 3 most satisfied customers.
select top 3 customer_id,Income_Level ,Customer_Satisfaction,
	rank()over(Partition by Income_Level order by Customer_Satisfaction desc)satisfied_customer
	from dbo.Consumer_Behavior_Analysis;

SELECT *
FROM (
    SELECT Customer_ID, Income_Level, Customer_Satisfaction, 
        RANK() OVER (PARTITION BY Income_Level ORDER BY Customer_Satisfaction DESC) AS Satisfaction_Rank
    FROM dbo.Consumer_Behavior_Analysis ) AS Ranked
WHERE Satisfaction_Rank <4;
--• For each Purchase_Channel, find average Time_to_Decision and standard deviation.
select Purchase_Channel,avg(Time_to_Decision)as time_f_Purchase,
		 STDEV(Time_to_Decision) AS StdDev_Time_to_Decision
		from dbo.Consumer_Behavior_Analysis
		group by Purchase_Channel;

--• Compare average Engagement_with_Ads levels (convert categorical to numeric).
select Engagement_with_Ads,
	avg(case when Engagement_with_Ads='None' then 0
			when Engagement_with_Ads='Low' then 1
			when Engagement_with_Ads='Medium' then 2
			when Engagement_with_Ads='High' then 3
			End
			)as Average_Engagement_With_Ads
	from dbo.Consumer_Behavior_Analysis
	group by Engagement_with_Ads;

select * from dbo.Consumer_Behavior_Analysis;
--• Identify loyal customers whose Brand_Loyalty >= 4 and Customer_Satisfaction >= 8 and compute their share in total revenue.
select
	Sum(case when Brand_Loyalty >=4 and Customer_Satisfaction>=8 then Purchase_Amount else 0 end ) as Loyal_Customer_Revenue,
	sum(purchase_Amount) as Total_Revenue,
	100*sum(case when Brand_Loyalty >=4 and Customer_Satisfaction>=8 then Purchase_Amount else 0 end ) /Sum(Purchase_Amount)as revenue_share
	from dbo.Consumer_Behavior_Analysis;

--• Find customers who spend above the 75th percentile of Purchase_Amount.
	select customer_id,Purchase_Amount  from dbo.Consumer_Behavior_Analysis
	where Purchase_Amount >=
		(select  distinct PERCENTILE_CONT(0.75) within group ( order by Purchase_Amount)over() from dbo.Consumer_Behavior_Analysis);
	
---------------------------------
--LEVEL 6 — Business-Oriented Case Studies
--• Identify the customer segment (based on Income_Level & Age group) that spends the most.
select 
	top 1 Income_Level,case when Age > 25 then '>25'
						when Age between 25 and 40 THEN '25-40' ELSE '>40' End as Age_group ,
						sum(Purchase_Amount)as Total_spend 
	from dbo.Consumer_Behavior_Analysis
	GROUP BY Income_Level,case when Age > 25 then '>25'
						when Age between 25 and 40 THEN '25-40' ELSE '>40' End 
	ORDER BY Total_Spend DESC;

--• Find the most profitable Purchase_Category among customers with High Social Media Influence.
select top 1 Purchase_Category,sum(Purchase_Amount) as Total_revenue from dbo.Consumer_Behavior_Analysis
		where Social_Media_Influence='High'
		group by Purchase_Category order by Total_revenue;

--• Determine whether Online or In-Store purchases have higher Customer_Satisfaction.
select Purchase_channel, avg(Customer_Satisfaction)as Avg_Customer_satisfaction from dbo.Consumer_Behavior_Analysis
	where Purchase_Channel in ('Online','In-Store')
	group by Purchase_Channel;

--• Analyze how Discount_Sensitivity affects Return_Rate.
select Discount_Sensitivity,Avg(Return_Rate) as Avgerage_Return_Rate 
	from dbo.Consumer_Behavior_Analysis
	group by Discount_Sensitivity;

--• Find the relationship between Brand_Loyalty and Frequency_of_Purchase.
select
	Brand_Loyalty,Avg(Frequency_of_Purchase) as Frequency_of_Purchase
	from dbo.Consumer_Behavior_Analysis
	group by Brand_Loyalty
	order by Brand_Loyalty;

--• Identify which Payment_Methods are preferred by Married customers.
select 
	customer_id,Payment_Method,Marital_Status
	from dbo.Consumer_Behavior_Analysis
	where Marital_Status='Married';

--• Compare average Purchase_Amount across different devices used for shopping.
select Device_Used_for_Shopping,avg(Purchase_Amount)as avg_Purchase
	from dbo.Consumer_Behavior_Analysis
	group by Device_Used_for_Shopping;

--• Find locations where customers spend the most time on research before buying.
select  top 1 Location,Avg(Time_Spent_on_Product_Research_hours)AS  Time_Spent from Consumer_Behavior_Analysis
	group by Location order by Time_Spent desc;

select * from Consumer_Behavior_Analysis;
--• Find customers who have high satisfaction (>=9) but low brand loyalty (<=2) — possible brand switchers.
select Customer_id,Customer_Satisfaction,Brand_Loyalty
	from dbo.Consumer_Behavior_Analysis
	where Customer_Satisfaction >=9 and Brand_Loyalty <=2;

--• Build a loyalty segment table grouped by Customer_Loyalty_Program_Member showing total customers, avg purchase amount, satisfaction, and loyalty.
select
	Customer_Loyalty_Program_Member,count(Customer_ID)as Total_Customer,Avg(Purchase_Amount)as Average_Purchase_amount,
	Avg(Customer_Satisfaction) as Average_satisfaction,avg(Brand_Loyalty) as Average_Brand_Loyalty
	from dbo.Consumer_Behavior_Analysis
	group by Customer_Loyalty_Program_Member;

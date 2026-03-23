----------------------------
--CASE STUDY : DMART--
----------------------------
--Author: Yogesh
--Date: 25/05/2022
--Tool used: SQL Server

/*  
Note: 
Table [weekly_sales] contains up to 17,117 rows.
SQL Server only allows us to insert 1000 rows each. Therefore, when inserting data to 
[weekly_sales], we have to break them down into many sets. 
Each Insert set contains about 1000 rows.
*/

CREATE DATABASE dmart;

USE DATABASE dmart;

CREATE SCHEMA qt;
DROP TABLE IF EXISTS dmart.qt.weekly_sales;
CREATE TABLE dmart.qt.weekly_sales (
  "week_date" VARCHAR(7),
  "region" VARCHAR(13),
  "platform" VARCHAR(20),
  "segment" VARCHAR(4),
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER
);
drop table dmart.qt.weekly_sales;
select * from qt.weekly_sales;

drop table qt.weekly_sales;
ALTER TABLE dmart.qt.weekly_sales
ADD week_date_actual DATE;

select * from qt.weekly_Sales order by region;
-- Step 2: Update new column by converting string to DATE
UPDATE dmart.qt.weekly_sales
SET week_date_actual = CONVERT(DATE, week_date,3); 

select * from qt.weekly_sales order by month_number desc;

ALTER TABLE qt.weekly_sales
DROP COLUMN week_date;
ALTER TABLE qt.weekly_sales
RENAME COLUMN week_date_actual TO week_date;


UPDATE dmart.qt.weekly_sales
SET week_date = PARSE(week_date AS DATE USING 'en-GB');


select day(week_date)as dates from dmart.qt.weekly_sales;
-----add column
ALTER TABLE qt.weekly_sales
ADD week_number int , month_number INT , calendar_year date;

ALTER TABLE qt.weekly_sales
ALTER COLUMN calendar_year int;

ALTER TABLE qt.weekly_sales DROP COLUMN Age_band;
ALTER TABLE qt.weekly_sales
ADD calendar_year int;

-- If week_date is a VARCHAR (e.g., 'dd/mm/yy'), first convert it to DATE
-- Example format '01/01/24' (dd/mm/yy)
-- Use TRY_CONVERT with style 3 (for dd/mm/yy)



UPDATE dmart.qt.weekly_sales SET week_number = datepart(week,week_date);
UPDATE dmart.qt.weekly_sales SET month_number = datepart(month,week_date);
UPDATE dmart.qt.weekly_sales SET calendar_year = datepart(year,week_date);

select * from qt.weekly_sales;

--add age_band column 

ALTER TABLE qt.weekly_sales
ADD Age_band varchar(30);

UPDATE qt.weekly_sales
SET Age_band = CASE 
    WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment, 1) = '2' THEN 'Middel_Aged'
    WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'retirees'
    ELSE 'unknown'
END;
-- add demographic column
ALTER TABLE qt.weekly_sales
ADD demographic varchar(30);
update qt.weekly_sales set demographic =
case when left(segment,1)='C' then 'Couples'
	when left(segment,1)='F' then 'Families'
	else 'unknown'
	end;

select * from qt.weekly_sales;
ALTER TABLE qt.weekly_sales DROP COLUMN avg_transaction;

-- add avg_transaction  column
ALTER TABLE qt.weekly_sales
ADD avg_transaction decimal(6,2);

update qt.weekly_sales set avg_transaction = (cast(sales as float)) /(cast (transactions as float))from qt.weekly_sales;

select * from qt.weekly_sales;
## Data Exploration
--1. What day of the week does each week_date fall on?
--→ Find out which weekday (e.g., Monday, Tuesday) each sales week starts on.
select Distinct week_date,datename(weekday,week_date)as weekday from qt.weekly_sales ;

--2. What range of week numbers are missing from the dataset?
with weeklist as(
select 1 as weeknum
union all
select weeknum+1 from weeklist
where weeknum+1 <=52
),
c2 as(
select distinct week_number from qt.weekly_sales 
)
select weeknum from weeklist wl left join c2 on wl.weeknum=c2.week_number
where c2.week_number is null
;
--3. How many purchases were made in total for each year?
--→ Count the total number of transactions for every year in the dataset.
select count(transactions),calendar_year  from qt.weekly_sales group by calendar_year order by calendar_year

;
--4. How much was sold in each region every month?
--→ Show total sales by region, broken down by month.
select region,month_number,SUM(CAST (sales AS BIGINT) ) from qt.weekly_sales 
group by region,month_number order by region
;
--5. How many transactions happened on each platform?
--→ Count purchases separately for the online store and the physical store.
SELECT COUNT(TRANSACTIONS) ,PLATFORM FROM QT.WEEKLY_SALES
GROUP BY PLATFORM
;
--6. What share of total sales came from Offline vs Online each month?
--→ Compare the percentage of monthly sales from the physical store vs. the online store.
SELECT SUM(TRANSACTIONS)TOTAL_SALES ,PLATFORM ,MONTH_NUMBER FROM QT.WEEKLY_SALES
GROUP BY PLATFORM, MONTH_NUMBER
ORDER BY MONTH_NUMBER,PLATFORM

WITH C1 AS(
	SELECT SUM(cast(sales as bigint))TOTAL_SALES_online ,MONTH_NUMBER FROM QT.WEEKLY_SALES
	WHERE PLATFORM='Online-Store'
	GROUP BY  MONTH_NUMBER
),
c2 as(
	SELECT SUM(cast(sales as bigint))TOTAL_SALES_offline ,MONTH_NUMBER FROM QT.WEEKLY_SALES
	WHERE PLATFORM='Offline-Store'
	GROUP BY  MONTH_NUMBER
)
SELECT c1.MONTH_NUMBER
,(CAST(TOTAL_SALES_online  AS FLOAT)*100/ (CAST(TOTAL_SALES_online AS FLOAT)+CAST(TOTAL_SALES_offline AS FLOAT))) AS PERCENTAGE_OF_online, 
(CAST (TOTAL_SALES_offline  AS FLOAT)*100/ (CAST(TOTAL_SALES_online AS FLOAT)+CAST(TOTAL_SALES_offline AS FLOAT)))AS PERCENTAGE_OF_offline
FROM C1 join c2 on c1.month_number=c2.month_number
ORDER BY MONTH_NUMBER;

--7. What percentage of total sales came from each demographic group each year?

--→ Break down annual sales by customer demographics (e.g., age or other groupings).
WITH C1 AS(
	SELECT SUM(cast(sales as bigint))TOTAL_SALES_couples ,calendar_year FROM QT.WEEKLY_SALES
	WHERE demographic='Couples'
	GROUP BY  calendar_year
),
c2 as(
	SELECT SUM(cast(sales as bigint))TOTAL_SALES_families ,calendar_year FROM QT.WEEKLY_SALES
	WHERE demographic='Families'
	GROUP BY  calendar_year
)
SELECT c1.calendar_year
,(CAST(TOTAL_SALES_couples  AS FLOAT)*100/ (CAST(TOTAL_SALES_couples AS FLOAT)+CAST(TOTAL_SALES_Families AS FLOAT))) AS PERCENTAGE_OF_couple, 
(CAST (TOTAL_SALES_Families  AS FLOAT)*100/ (CAST(TOTAL_SALES_couples AS FLOAT)+CAST(TOTAL_SALES_Families AS FLOAT)))AS PERCENTAGE_OF_families
FROM C1 join c2 on c1.calendar_year=c2.calendar_year
ORDER BY calendar_year;
--8. Which age groups and demographic categories had the highest sales in physical stores?
--→ Find out which age and demographic combinations contribute most to Offline-Store sales.

select  top 1 Age_band,demographic, sum(cast(sales as bigint))as higest_sales from qt.weekly_sales where PLATFORM='offline-store'and demographic !='unknown'
group by Age_band,demographic order by higest_sales desc
--9. Can we use the avg_transaction column to calculate average purchase size by year and platform? If not, how should we do it?
--→ Check if the avg_transaction column gives us correct yearly average sales per transaction for Offline vs Online. If it doesn't,
--figure out how to calculate it manually (e.g., by dividing total sales by total transactions).
 select avg_transaction,sales,calendar_year,transactions,platform from qt.weekly_sales;
select calendar_year,platform ,(total_sales/total_transactions) as avg_purchase from(
select calendar_year,platform,sum(cast (sales as bigint))as total_Sales,sum(transactions) as total_transactions from qt.weekly_sales
group by calendar_year,platform
) as details order by calendar_year;

--select calendar_year,platform ,avg(avg_transaction) from qt.weekly_sales group by calendar_year,platform,transactions

--### Pre-Change vs Post-Change Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where the DMart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

select * from   qt.weekly_sales;

--1. What is the total sales for the 4 weeks pre and post 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
select  sum(cast(sales as bigint)),month_number from qt.weekly_sales group by month_number
with c1 as(
--select distinct top 4 week_Date,sum(sales)total_sales from qt.weekly_sales where week_date<'2020-06-15' group by week_Date  order by week_date  desc
SELECT SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales WHERE week_date >= DATEADD(WEEK, -4, '2020-06-15')AND week_date < '2020-06-15'
),
c2 as(
--select distinct top 4 week_Date,sum(sales)total_sales from qt.weekly_sales where week_date>='2020-06-15' group by week_Date  order by week_date asc
SELECT  SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales WHERE week_date < DATEADD(WEEK, 4, '2020-06-15')AND week_date >= '2020-06-15'
),
c3 as(
SELECT 
    (SELECT SUM(cast( total_sales as bigint)) FROM c1) AS total_sales_before,
    (SELECT SUM(cast (total_sales as bigint)) FROM c2) AS total_sales_after
	)
select total_sales_before,total_sales_after,
((total_sales_after -total_sales_before )/cast(total_sales_before as float))*100 as growth_or_reduction from c3;


--2. What is the total sales for the 12 weeks pre and post 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
with c1 as(
SELECT calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales
WHERE week_date >= DATEADD(WEEK, -12, '2020-06-15')AND week_date < '2020-06-15'
group by calendar_year
),
c2 as(
--select distinct top 4 week_Date,sum(sales)total_sales from qt.weekly_sales where week_date>='2020-06-15' group by week_Date  order by week_date asc
SELECT  calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales 
WHERE week_date < DATEADD(WEEK, 12, '2020-06-15')AND week_date >= '2020-06-15'
group by calendar_year
),
c3 as( select  c1.calendar_year,SUM(cast( c1.total_sales as bigint))  AS total_sales_before,
SUM(cast (c2.total_sales as bigint))as total_sales_after FROM c1,c2
group by c1.calendar_year)

select calendar_year,total_sales_before,total_sales_after,
round(((total_sales_after -total_sales_before )/cast(total_sales_before as float)),4)*100 as growth_or_reduction into #pqr from c3

select * from #pqr
--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019? 
--2018
with c1 as(
SELECT calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales
WHERE week_date >= DATEADD(WEEK, -12, '2018-06-15')AND week_date < '2018-06-15'
group by calendar_year
),
c2 as(
--select distinct top 4 week_Date,sum(sales)total_sales from qt.weekly_sales where week_date>='2020-06-15' group by week_Date  order by week_date asc
SELECT  calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales 
WHERE week_date < DATEADD(WEEK, 12, '2018-06-15')AND week_date >= '2018-06-15'
group by calendar_year
),
c3 as( select  c1.calendar_year,SUM(cast( c1.total_sales as bigint))  AS total_sales_before,
SUM(cast (c2.total_sales as bigint))as total_sales_after FROM c1,c2
group by c1.calendar_year)

select calendar_year,total_sales_before,total_sales_after,
round(((total_sales_after -total_sales_before )/cast(total_sales_before as float)),4)*100 as growth_or_reduction into #jklm  from c3

select * from #jklm
--2019
with c1 as(
SELECT calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales
WHERE week_date >= DATEADD(WEEK, -12, '2019-06-15')AND week_date < '2019-06-15'
group by calendar_year
),
c2 as(
--select distinct top 4 week_Date,sum(sales)total_sales from qt.weekly_sales where week_date>='2020-06-15' group by week_Date  order by week_date asc
SELECT  calendar_year,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales 
WHERE week_date < DATEADD(WEEK, 12, '2019-06-15')AND week_date >= '2019-06-15'
group by calendar_year
),
c3 as( select  c1.calendar_year,SUM(cast( c1.total_sales as bigint))  AS total_sales_before,
SUM(cast (c2.total_sales as bigint))as total_sales_after FROM c1,c2
group by c1.calendar_year)

select calendar_year,total_sales_before,total_sales_after,
round(((total_sales_after -total_sales_before )/cast(total_sales_before as float)),4)*100 as growth_or_reduction into #abcd from c3

select * from #jklm
union all
select * from #abcd
union all
select * from #pqr
### Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
1. region
2. platform
3. age_band
4. demographic
5. customer_type

with c1 as(
	select region,platform,age_band,demographic,customer_Type,
	SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales
	WHERE week_date >= DATEADD(WEEK, -12, '2020-06-15')AND week_date < '2020-06-15'
	group by region,platform,age_band,demographic,customer_Type
),
c2 as(
SELECT  region,platform,age_band,demographic,customer_Type,SUM(CAST(sales AS BIGINT)) AS TOTAL_sALES FROM qt.weekly_sales 
WHERE week_date < DATEADD(WEEK, 12, '2020-06-15')AND week_date >= '2020-06-15'
group by  region,platform,age_band,demographic,customer_Type 
),
c3 as( 
select c1.region,c1.platform,c1.age_band,c1.demographic,c1.customer_Type, SUM(cast( c1.total_sales as bigint))  AS total_sales_before,
SUM(cast (c2.total_sales as bigint))as total_sales_after FROM c1,c2
group by c1.region,c1.platform,c1.age_band,c1.demographic,c1.customer_Type
)
select * from c3
order by customer_type

select total_sales_before,total_sales_after,
round(((total_sales_after -total_sales_before )/cast(total_sales_before as float)),4)*100 as growth_or_reduction into #abcd from c3

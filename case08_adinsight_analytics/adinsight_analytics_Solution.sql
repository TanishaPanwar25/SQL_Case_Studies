--create databases
create database adinsight_analytics;
use adinsight_analytics;
-- Create schema

CREATE SCHEMA adinsight_analytics;
GO

-- Drop table if exists (MSSQL syntax)
IF OBJECT_ID('adinsight_analytics.raw_json_data', 'U') IS NOT NULL
  DROP TABLE adinsight_analytics.raw_json_data;
GO

-- Create table for raw JSON data
CREATE TABLE adinsight_analytics.raw_json_data (
  raw_data NVARCHAR(MAX)
);
GO

-- Create interest map table
CREATE TABLE adinsight_analytics.interest_map (
  id INT PRIMARY KEY,
  interest_name NVARCHAR(255),
  interest_summary NVARCHAR(MAX),
  created_at DATETIME,
  last_modified DATETIME
);
GO
drop table adinsight_analytics.interest_map;

INSERT INTO adinsight_analytics.interest_map (id,interest_name,interest_summary,created_at,last_modified)
SELECT id,interest_name,interest_summary,created_at,last_modified
FROM adinsight_analytics.firsttablerecord;

select * from   adinsight_analytics.interest_map;


-- Update NULL values in MSSQL
UPDATE adinsight_analytics.interest_map
SET interest_summary = NULL
WHERE interest_summary = '';
GO
drop table adinsight_analytics.interest_metrics 
-- Create the interest_metrics table
CREATE TABLE adinsight_analytics.interest_metrics (
  month TINYINT,
  year SMALLINT,
  month_year CHAR(10),
  interest_id INT,
  composition FLOAT,
  index_value FLOAT,
  ranking INT,
  percentile_ranking FLOAT
);
GO
SELECT * FROM adinsight_analytics.inter;

INSERT INTO adinsight_analytics.interest_metrics (month,year,month_year,interest_id,composition,index_value,ranking,percentile_ranking)
SELECT month,year,month_year,interest_id,composition,index_value,ranking,percentile_ranking
FROM adinsight_analytics.inter;

select * from adinsight_analytics.interest_metrics;


**AdInsight Analytics: Case Study Questions**

The following are core business questions designed to be explored using SQL queries and logical reasoning. These will help AdInsight Analytics gain actionable insights into customer behavior and interest segmentation.

---

### Data Exploration and Cleansing
select * from adinsight_analytics.interest_metrics
select * from adinsight_analytics.interest_map
--1. Update the `month_year` column in `adinsight_analytics.
--interest_metrics` to be of `DATE` type, with values representing the first day of each month.
update adinsight_analytics.interest_metrics
set month_year = ('01-') + month_year as date )

alter table adinsight_analytics.interest_metrics
alter column month_year date 

--2. Count the total number of records for each `month_year` in the `interest_metrics` table, sorted chronologically, ensuring that NULL values (if any) appear at the top.
select month_year,count(*)as total_number from adinsight_analytics.interest_metrics
group by month_year
order by month_year asc
--3. Based on your understanding, what steps should be taken to handle NULL values in the `month_year` column?
select * from adinsight_analytics.interest_metrics where month_year is not null;

--4. How many `interest_id` values exist in `interest_metrics` but not in `interest_map`? And how many exist in `interest_map` but not in `interest_metrics`?
with c1 as(
select count(*)as interest_id_count from (
select interest_id as i_id from adinsight_analytics.interest_metrics where interest_id is not null
except 
select Id  from adinsight_analytics.interest_map)as interest_id_count
),
c2 as(
select count(*)as id_count from (
select id from adinsight_analytics.interest_map where id is not null
except 
select  interest_id from  adinsight_analytics.interest_metrics)as id_count
)
select c1.interest_id_count,c2.id_count from c1,c2
--5. Summarize the `id` values from the `interest_map` table by total record count.
select count (distinct id) from adinsight_analytics.interest_map
select count(*),id from adinsight_analytics.interest_map group by id
--6. What type of join is most appropriate between the `interest_metrics` and `interest_map` tables for analysis?
--Justify your approach and verify it by retrieving data where `interest_id = 21246`,
--including all columns from `interest_metrics` and all except `id` from `interest_map`.
select ime.*,
	im.interest_name,
	im.interest_summary,
	im.created_at,
	im.last_modified
from adinsight_analytics.interest_metrics as ime
left join adinsight_analytics.interest_map as im
on ime.interest_id=im.id
where interest_id=21246


--7. Are there any rows in the joined data where `month_year` is earlier than `created_at` in `interest_map`?
--Are these values valid? Why or why not?
select  month_year,created_At from adinsight_analytics.interest_metrics as ime
left join adinsight_analytics.interest_map as im
on ime.interest_id=im.id
where ime.month_year < im.created_at

--select  month,month(month_year) from adinsight_analytics.interest_metrics

--update adinsight_analytics.interest_metrics set month_year=try_cast(concat(year,'-',month,'-01') as date);
### Interest Analysis

--8. Which interests appear consistently across all `month_year` values in the dataset?
WITH i1 AS (
  SELECT COUNT(DISTINCT month_year) AS total_months FROM  adinsight_analytics.interest_metrics
),
i2 AS (SELECT interest_id, COUNT(DISTINCT month_year) AS months_present FROM  adinsight_analytics.interest_metrics
  GROUP BY interest_id
)
SELECT im.interest_id
FROM i2 im JOIN i1 mc ON im.months_present = mc.total_months;

--9. Calculate the cumulative percentage of interest records starting from those present in 14 months.
--What is the `total_months` value where the cumulative percentage surpasses 90%?
with c1 as(
select interest_id,count( month)as total_month from  adinsight_analytics.interest_metrics
where month is not null
group by interest_id 
),
c2 as(
select interest_id,total_month,count(*) as interest_count from c1
group by total_month,interest_id
),
list as(
select interest_id,round(cume_dist() over (order by total_month desc),4)*100 as cume_dist from c2
)
select interest_id,cume_dist from list where cume_dist>90 and interest_id is not null;
--10. If interests with `total_months` below this threshold are removed, how many records would be excluded?
with c1 as(
select interest_id,count( month)as total_month from  adinsight_analytics.interest_metrics
where month is not null
group by interest_id 
),
c2 as(
select interest_id,total_month,count(*) as interest_count from c1
group by total_month,interest_id
),
list as(
select interest_id,round(cume_dist() over (order by total_month desc),4)*100 as cume_dist from c2
)
select count(interest_id) from list where cume_dist<90 and interest_id is not null;

--11. Evaluate whether removing these lower-coverage interests is justified from a business perspective.
--Provide a comparison between a segment with full 14-month presence and one that would be removed.
with c1 as(
select interest_id,count(*)as total_month from adinsight_analytics.interest_metrics
 where interest_id is not null
 group by interest_id
),
c2 as(
select interest_id,total_month,round(cume_dist() over(order by total_month desc),4)*100
as cume_dist from c1
)
--select * from c2,
,c3 as(
select 
count(case when cume_dist<90 then 1 end ) as low_conversion,
count(*)as full_conversion from c2 
),
c4 as(
select top 1 interest_id,total_month,cume_dist from c2 where total_month=14 order by interest_id
),
c5 as(
select top 1 interest_id,total_month,cume_dist from c2 where  cume_dist<90  order by cume_dist asc
) 
select 
c3.low_conversion,c4.interest_id,c4.total_month,c4.cume_dist,c3.full_conversion,c5.interest_id,c5.total_month,c5.cume_dist
from c3,c4,c5


--12. After filtering out lower-coverage interests, how many unique interests remain for each month?

with cte as (
select distinct month_year, avg(composition) as average
from adinsight_analytics.interest_metrics
where month_year is not null
group by month_year
),
cte2 as (
select month_year, interest_id,composition
from adinsight_analytics.interest_metrics 
where Interest_id is not null and month_year is not null
),
cte3 as (
select cte2.month_year, cte2.interest_id, cte2.composition, cte.average
from cte join cte2
on cte.month_year = cte2.month_year
where cte2.composition >= cte.average 
)
select month_year, count(interest_id) as unique_interest_count from cte3
group by month_year
order by month_year

### Segment Analysis

--13. From the filtered dataset (interests present in at least 6 months),
--identify the top 10 and bottom 10 interests based on their maximum `composition` value.
--Also, retain the corresponding `month_year`.
with cte as (
select interest_id,count(distinct month_year)as total_month 
from adinsight_analytics.interest_metrics
where interest_id is not null
group by interest_id having count(distinct month_year)>=6
),
cte2 as(
select c.interest_id,im.month_year,c.total_month,composition,rank()over(partition by im.interest_id order by composition desc) as row_num
from adinsight_analytics.interest_metrics im
join cte c on im.interest_id=c.interest_id
)
select * from cte2
,
top1 as(
select top 10 interest_id,month_year,composition,total_month,row_num,row_number() over(order by composition desc) as rownumber from cte2 where row_num=1 order by composition desc
),
bottom1 as(
select top 10 interest_id,month_year,composition,total_month,row_num,row_number() over(order by composition) as rownumber from cte2 where row_num=1 order by composition asc
)
--select* from bottom1
select* from top1 join bottom1 on top1.rownumber=bottom1.rownumber

--14. Identify the five interests with the lowest average `ranking` value.
with cte as (
select interest_id,count(distinct month_year)as total_month,ranking ,avg(composition)as average 
from adinsight_analytics.interest_metrics
where interest_id is not null
group by interest_id,ranking 
),
bottom1 as(
select  top 5 interest_id as bottom_interest_id,ranking,
total_month,average as bottom_composition from cte order by average asc
)
select* from  bottom1

with cte as (
select interest_id,count(distinct month_year)as total_month,avg(ranking)as average 
from adinsight_analytics.interest_metrics
where interest_id is not null
group by interest_id 
),
bottom1 as(
select  top 5 interest_id as bottom_interest_id,row_number() over(order by average asc)as row_num,
total_month,average as bottom_composition from cte order by average asc
)
select* from  bottom1

--15. Determine the five interests with the highest standard deviation in their `percentile_ranking`.
select  top 5 interest_id,interest_name,
STDEV(percentile_ranking) as std_deviation
from adinsight_analytics.interest_metrics ime
left join adinsight_analytics.interest_map im
on ime.interest_id=im.id
where interest_id is not null and month_year is not null
group by interest_id,interest_name
order by std_deviation desc
;
 
--16. For the five interests found in the previous step, 
--report the minimum and maximum `percentile_ranking` values and their corresponding `month_year`. 
--What trends or patterns can you infer from these fluctuations?

--select * from adinsight_analytics.interest_metrics where percentile_ranking=0
--select * from adinsight_analytics.interest_map where id=6260
-------------------------------------------------
with c1 as(
select interest_id,interest_name,
STDEV(percentile_ranking) as std_deviation
from adinsight_analytics.interest_metrics ime
left join adinsight_analytics.interest_map im
on ime.interest_id=im.id
where interest_id is not null and month_year is not null
group by interest_id,interest_name
),
c2 as (
select c1.interest_id,c1.interest_name,c1.std_deviation,month_year,percentile_Ranking,rank()over(partition by c1.interest_id order by percentile_ranking desc)as rank_desc,
rank()over(partition by c1.interest_id order by percentile_ranking asc)
as rank_asc from c1
join adinsight_analytics.interest_metrics ime on c1.interest_id=ime.interest_id
),
maximum as(
    SELECT interest_id,interest_name,std_deviation,month_year AS max_month, percentile_ranking AS max_percentile
    FROM c2 WHERE rank_desc = 1
),
minimum as(
    SELECT interest_id,interest_name,std_deviation,month_year AS min_month, percentile_ranking AS min_percentile
    FROM c2 WHERE rank_asc = 1
	)

SELECT mx.interest_id,mx.interest_name,mx.std_deviation,mx.max_month,mx.max_percentile,mi.min_month,mi.min_percentile
FROM maximum mx JOIN minimum mi  ON mx.interest_id = mi.interest_id;

--17. Based on composition and ranking data, describe the overall customer profile represented in this segment.
--What types of products/services should be targeted, and what should be avoided?


### Index Analysis

--18. Calculate the average composition for each interest by dividing `composition` by `index_value`,rounded to 2 decimal places.
with cte as(
select interest_id, composition/index_value as avg_composition_each_int
from adinsight_analytics.interest_metrics
where interest_id is not null
)
select interest_id, round(avg(avg_composition_each_int),2) as avg_comp
into   #avg_compositions
from cte
group by interest_id order by interest_id;
  
select  interest_id,avg_comp from  #avg_compositions order by avg_comp desc
--19. For each month, identify the top 10 interests based on this derived average composition.

with cte as(
select ac.interest_id, month_year, avg_comp, rank() over(partition by month_year order by ac.avg_comp desc) rank_comp
from adinsight_analytics.interest_metrics im join #avg_compositions ac 
on im.interest_id = ac.interest_id
where month_year is not null)

select month_year, interest_id, round(avg_comp,2) avg_comp, rank_comp
into   #composition
from cte
where rank_comp <=10
order by month_year;

select * from #composition
--20. Among these top 10 interests, which interest appears most frequently?
with c1 as(
select interest_id,count(avg_comp)total from #composition
group by interest_id
)
select interest_id,total from c1
where total=(select max(total) from c1)

--21. Calculate the average of these monthly top 10 average compositions across all months.
with c1 as(
select interest_id,month_year,avg(composition/index_value) as avg_compositions from adinsight_analytics.interest_metrics
where interest_id is not null
group by interest_id,month_year
),
c2 as(
select *, row_number() over(partition by month_year order by avg_compositions desc) as rn
 from c1
)
select round(avg(avg_compositions), 4) as final_avg,month_year
from c2
where rn <= 10 and month_year is not null
group by month_year
--22. From September 2018 to August 2019, calculate a 3-month rolling average of the highest average composition. 
--Also, include the top interest names for the current, 1-month-ago, and 2-months-ago periods.

with c1 as(
select interest_id,month_year,avg(composition)as average_com
					from adinsight_analytics.interest_metrics
					where interest_id is not null and month_year is not null and
					month_year between '2018-09-01' and '2019-08-01'
					group by interest_id,month_year
					),
c2 as(
select month_year,interest_id ,max(average_com)as highest_average from c1
group by month_year, interest_id
),
c3 as(
 select highest_average,avg(highest_average) over(order by month_year
 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_month from c2
 )
 select * from c3

--23. Provide a plausible explanation for the month-to-month changes in the top average composition.
--Could it indicate any risks or insights into AdInsight’s business model?

---

### Sample Output for Rolling Average (Q22)

| month\_year | interest\_name             | max\_index\_composition | 3\_month\_moving\_avg | 1\_month\_ago                    | 2\_months\_ago                   |
| ----------- | -------------------------- | ----------------------- | --------------------- | -------------------------------- | -------------------------------- |
| 2018-09-01  | Work Comes First Travelers | 8.26                    | 7.61                  | Las Vegas Trip Planners: 7.21    | Las Vegas Trip Planners: 7.36    |
| 2018-10-01  | Work Comes First Travelers | 9.14                    | 8.20                  | Work Comes First Travelers: 8.26 | Las Vegas Trip Planners: 7.21    |
| 2018-11-01  | Work Comes First Travelers | 8.28                    | 8.56                  | Work Comes First Travelers: 9.14 | Work Comes First Travelers: 8.26 |
| ...         | ...                        | ...                     | ...                   | ...                              | ...                              |

---


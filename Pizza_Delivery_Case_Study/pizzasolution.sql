/*mssql-->pgadmin
#nvarchar--varchar
#dateTime -- Timestamp */
-->MSSQL -->SELECT TRY_CAST(GETDATE() as TIME) RESULT;  TRY_CAST(expr AS type)	
-- IN PGADMIN -->CURRENT_TIMESTAMP
-->expr::type or CAST(expr AS type)
SELECT CAST(CURRENT_TIMESTAMP as TIME) RESULT;
-- Create Schema
CREATE SCHEMA pizza_delivery_india;

-- Drop tables if exist
DROP TABLE IF EXISTS pizza_delivery_india.riders;
DROP TABLE IF EXISTS pizza_delivery_india.customer_orders;
DROP TABLE IF EXISTS pizza_delivery_india.rider_orders;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_names;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_recipes;
DROP TABLE IF EXISTS pizza_delivery_india.pizza_toppings;

-- Riders Table
CREATE TABLE pizza_delivery_india.riders (
  rider_id INT,
  registration_date DATE
);

INSERT INTO pizza_delivery_india.riders (rider_id, registration_date) VALUES
  (1, '2023-01-01'),
  (2, '2023-01-05'),
  (3, '2023-01-10'),
  (4, '2023-01-15');

-- Customer Orders
CREATE TABLE pizza_delivery_india.customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(10),
  extras VARCHAR(10),
  order_time Timestamp
);

INSERT INTO pizza_delivery_india.customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 201, 1, '', '', '2023-01-01 18:05:02'),
  (2, 201, 1, '', '', '2023-01-01 19:00:52'),
  (3, 202, 1, '', '', '2023-01-02 23:51:23'),
  (3, 202, 2, '', NULL, '2023-01-02 23:51:23'),
  (4, 203, 1, '4', '', '2023-01-04 13:23:46'),
  (4, 203, 2, '4', '', '2023-01-04 13:23:46'),
  (5, 204, 1, NULL, '1', '2023-01-08 21:00:29'),
  (6, 201, 2, NULL, NULL, '2023-01-08 21:03:13'),
  (7, 205, 2, NULL, '1', '2023-01-08 21:20:29'),
  (8, 202, 1, NULL, NULL, '2023-01-09 23:54:33'),
  (9, 203, 1, '4', '1, 5', '2023-01-10 11:22:59'),
  (10, 204, 1, NULL, NULL, '2023-01-11 18:34:49'),
  (10, 204, 1, '2, 6', '1, 4', '2023-01-11 18:34:49');

-- Rider Orders
CREATE TABLE pizza_delivery_india.rider_orders (
  order_id INT,
  rider_id INT,
  pickup_time VARCHAR(20),
  distance VARCHAR(10),
  duration VARCHAR(15),
  cancellation VARCHAR(50)
);

INSERT INTO pizza_delivery_india.rider_orders (order_id, rider_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2023-01-01 18:15:34', '5km', '32 minutes', ''),
  (2, 1, '2023-01-01 19:10:54', '6km', '27 minutes', ''),
  (3, 1, '2023-01-03 00:12:37', '4.2km', '20 mins', NULL),
  (4, 2, '2023-01-04 13:53:03', '5.5km', '40', NULL),
  (5, 3, '2023-01-08 21:10:57', '3.3km', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2023-01-08 21:30:45', '6.1km', '25mins', NULL),
  (8, 2, '2023-01-10 00:15:02', '7.2km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2023-01-11 18:50:20', '2.8km', '10minutes', NULL);

-- Pizza Names
CREATE TABLE pizza_delivery_india.pizza_names (
  pizza_id INT,
  pizza_name VARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Paneer Tikka'),
  (2, 'Veggie Delight');

-- Pizza Recipes
CREATE TABLE pizza_delivery_india.pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

--IN MSSQL-->select pizza_id,toppings CROSS_APPLY STRING_SPLIT(TOPPINGS,',');
--IN PGADMIN-->
SELECT pizza_id, unnest(string_to_array(toppings, ',')) AS topping
FROM pizza_delivery_india.pizza_recipes;

-- Pizza Toppings
CREATE TABLE pizza_delivery_india.pizza_toppings (
  topping_id INT,
  topping_name VARCHAR(100)
);

INSERT INTO pizza_delivery_india.pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Paneer'),
  (2, 'Schezwan Sauce'),
  (3, 'Tandoori Chicken'),
  (4, 'Cheese'),
  (5, 'Corn'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Capsicum'),
  (9, 'Red Peppers'),
  (10, 'Black Olives'),
  (11, 'Tomatoes'),
  (12, 'Mint Mayo');
select * from pizza_delivery_india.pizza_toppings;

select * from pizza_delivery_india.riders ;
select * from pizza_delivery_india.customer_orders ;
select * from pizza_delivery_india.rider_orders;
select * from pizza_delivery_india.pizza_names;
select * from pizza_delivery_india.pizza_recipes;
select * from pizza_delivery_india.pizza_toppings;

--1. How many pizzas were ordered?
select count(p.pizza_id),p.pizza_name from pizza_delivery_india.customer_orders as c 
join pizza_delivery_india.pizza_names as p on c.pizza_id=p.pizza_id
group by c.pizza_id,p.pizza_name,c.order_id;

select count(pizza_id) as no_of_pizzas_ordered from pizza_delivery_india.customer_orders;

--2. How many unique customer orders were made?
select count(distinct customer_id) as unique_customer from  pizza_delivery_india.customer_orders ;

--3. How many successful orders were delivered by each rider?
select rider_id,count(order_id) as successful_orders 
from pizza_delivery_india.rider_orders where cancellation is null group by rider_id ;

select rider_id,count(pickup_time) as successful_orders 
from pizza_delivery_india.rider_orders group by rider_id ;

--4. How many of each type of pizza was delivered?
select count(c.pizza_id) as total_count,p.pizza_name from pizza_delivery_india.customer_orders as c 
join pizza_delivery_india.pizza_names as p on c.pizza_id=p.pizza_id
join pizza_delivery_india.rider_orders as pr on c.order_id = pr.order_id
where cancellation is null or cancellation = ' ' or pickup_time is not null
group by c.pizza_id,pizza_name;

--5. How many 'Paneer Tikka' and 'Veggie Delight' pizzas were ordered by each customer?
select count(c.pizza_id) as total_count,p.pizza_name ,c.customer_id from pizza_delivery_india.customer_orders as c  
join pizza_delivery_india.pizza_names as p on c.pizza_id=p.pizza_id group by c.customer_id,p.pizza_id,p.pizza_name order by c.customer_id ;
----6. What was the maximum number of pizzas delivered in a single order?
select count(c.pizza_id) AS maximumnumber_of_pizza,pr.order_id from pizza_delivery_india.customer_orders as c 
join pizza_delivery_india.pizza_names as p on c.pizza_id=p.pizza_id
join pizza_delivery_india.rider_orders as pr on c.order_id = pr.order_id 
where cancellation is null or cancellation = ' ' or pickup_time is not null
group by pr.order_id  order by order_id;
--row wali values ko column m present krna ho to case use krte hen 
--7. For each customer, how many delivered pizzas had at least 1 change (extras or exclusions) and how many had no changes?
	SELECT c.customer_id,
    COUNT(CASE 
              WHEN (c.exclusions IS NOT NULL AND c.exclusions <> '') 
                OR (c.extras IS NOT NULL AND c.extras <> '') 
              THEN 1 
         END) AS pizzas_with_changes,
    COUNT(CASE 
              WHEN (c.exclusions IS NULL OR c.exclusions = '') 
               AND (c.extras IS NULL OR c.extras = '') 
              THEN 1 
         END) AS pizzas_without_changes
FROM 
    pizza_delivery_india.customer_orders c
JOIN  pizza_delivery_india.pizza_names p ON c.pizza_id = p.pizza_id
JOIN  pizza_delivery_india.rider_orders pr ON c.order_id = pr.order_id
WHERE 
    cancellation is null or cancellation=''
GROUP BY c.customer_id
ORDER BY c.customer_id;

	select count(c.pizza_id) over(partition by customer_id)AS total,c.customer_id from 
	pizza_delivery_india.customer_orders as c 
	join pizza_delivery_india.pizza_names as p on c.pizza_id=p.pizza_id
	join pizza_delivery_india.rider_orders as pr on c.order_id = pr.order_id where c.exclusions is not null or c.extras is not null
	group by c.customer_id,c.pizza_id

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT p.pizza_id,pr.order_id,count(c.pizza_id) as total
FROM pizza_delivery_india.customer_orders c
JOIN pizza_delivery_india.pizza_names p ON c.pizza_id = p.pizza_id
JOIN pizza_delivery_india.rider_orders pr ON c.order_id = pr.order_id
WHERE 
    (c.exclusions IS NOT NULL AND c.exclusions != '') AND
    (c.extras IS NOT NULL AND c.extras != '') AND
    (pr.cancellation IS NULL OR pr.cancellation = '')
group by c.pizza_id,p.pizza_id,pr.order_id;

--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	COUNT(order_id) AS order_count,extract(hour from order_time) AS hour
FROM pizza_delivery_india.customer_orders GROUP BY hour order by order_count;
--10. What was the volume of orders for each day of the week?  
select count(order_id)AS order_count,EXTRACT(DOW FROM ORDER_TIME) as Day

from pizza_delivery_india.customer_orders GROUP BY Day order by Day;
(show name )
--11. How many riders signed up for each 1-week period starting from 2023-01-01?
 select count(rider_id) AS rider_count,r.registration_date ,EXTRACT('week' FROM r.registration_date )AS week_num from pizza_delivery_india.riders  as r 
 where r.registration_date >= '2023-01-01' 
GROUP BY r.registration_date ORDER BY EXTRACT('week' FROM r.registration_date );

select DATEdiff('week','2023-01-01',registration_date)+1 week_num,count(rider_id)as RIDER_COUNT,registration_date from pizza_delivery_india.riders
where registration_date >= '2023-01-01' group by DATEdiff('week','2023-01-01',registration_date)+1, registration_date;
-- 12. What was the average time in minutes it took for each rider to arrive at Pizza Delivery HQ to pick up the order?
SELECT pr.rider_id,
     AVG(EXTRACT(EPOCH FROM (CAST(pr.pickup_time AS timestamp) - CAST(pc.order_time AS timestamp) )) / 60.0 ) AS avg_pickup_time_minutes
FROM  pizza_delivery_india.customer_orders AS pc
JOIN  pizza_delivery_india.rider_orders AS pr  ON pc.order_id = pr.order_id
WHERE  pr.pickup_time IS NOT NULL  AND pc.order_time IS NOT NULL
GROUP BY pr.rider_id
ORDER BY avg_pickup_time_minutes;


--in this one duplicate recore so use distinct for handel it 
SELECT distinct pr.rider_id,
     AVG(EXTRACT(EPOCH FROM (CAST(pr.pickup_time AS timestamp) - CAST(pc.order_time AS timestamp) )) / 60.0 ) AS avg_pickup_time_minutes
FROM  pizza_delivery_india.customer_orders AS pc
JOIN  pizza_delivery_india.rider_orders AS pr  ON pc.order_id = pr.order_id
WHERE  pr.pickup_time IS NOT NULL  AND pc.order_time IS NOT NULL
GROUP BY pr.rider_id
ORDER BY avg_pickup_time_minutes;
--/60.0 Converts seconds to minutes (float). and epoch from .. give in second

--13. Is there any relationship between the number of pizzas in an order and how long it takes to prepare?
SELECT pr.order_id,count(pizza_id),
     EXTRACT(EPOCH FROM (CAST(pr.pickup_time AS timestamp) - CAST(pc.order_time AS timestamp) ) / 60.0 ) AS pickup_time_minutes
FROM  pizza_delivery_india.customer_orders AS pc
JOIN  pizza_delivery_india.rider_orders AS pr  ON pc.order_id = pr.order_id
GROUP BY pr.order_id,pickup_time_minutes
ORDER BY pr.order_id;
(null remove?)
----14. What was the average distance traveled for each customer?

SELECT 
    pc.customer_id,AVG(CAST(REPLACE(LOWER(TRIM(pr.distance)), 'km', '') AS FLOAT)) AS avg_distance_km
FROM  pizza_delivery_india.rider_orders AS pr
JOIN pizza_delivery_india.customer_orders AS pc ON pr.order_id = pc.order_id
GROUP BY pc.customer_id ORDER BY pc.customer_id;
-------------------------
SELECT 
    pc.customer_id,AVG(CAST(left(pr.distance,1)AS INT)) AS avg_distance_km
FROM  pizza_delivery_india.rider_orders AS pr
JOIN pizza_delivery_india.customer_orders AS pc ON pr.order_id = pc.order_id
GROUP BY pc.customer_id ORDER BY pc.customer_id;
--15. What was the difference between the longest and shortest delivery durations across all orders?
 
select MAX(CAST(left(duration,2)AS INT)),MIN(CAST(left(duration,2) AS INT)),
    MAX(CAST(left(duration,2)AS INT)) -
    MIN(CAST(left(duration,2) AS INT)) 
    AS diff
from pizza_delivery_india.rider_orders;
--16. What was the average speed (in km/h) for each rider per delivery? Do you notice any trends?
--select * from pizza_delivery_india.rider_orders;
--s=d/t

with speed AS(	
select rider_id,sum(CAST(REPLACE(LOWER(TRIM(distance)), 'km', '')AS FLOAT)) AS ndistance,
	sum(CAST(left(duration,2)AS float)/60.0 ) AS nduration
	from pizza_delivery_india.rider_orders group by rider_id
	)
	select rider_id,avg(ndistance/nduration) from speed group by rider_id;
--17. What is the successful delivery percentage for each rider?
SELECT rider_id,COUNT(*) AS total_orders,COUNT(*) - COUNT(cancellation) AS successful_deliveries,
    ROUND((COUNT(*) - COUNT(cancellation)) * 100.0 / COUNT(*), 2) AS success_percentage
FROM pizza_delivery_india.rider_orders
GROUP BY rider_id;
 (check it )

p/w*100


 ----18. What are the standard ingredients for each pizza?
with cte as(
select pizza_id,
	-- cross apply string_split('toppings',',') 
	unnest(string_to_array(toppings,',')) as topping_id
	from pizza_delivery_india.pizza_recipes),
	cte2 as(
	select topping_id,topping_name from pizza_delivery_india.pizza_toppings
	)

select pizza_id,string_Agg(topping_name,',')As topping_NAME from  cte,cte2
where CAST(cte.topping_id AS INT)= CAST(cte2.topping_id AS INT)
group by pizza_id order by pizza_id;
--other solution  in mssql
select pn.pizza_name,String_AGG(pt.topping_name,',')AS Standard from
pizza_delivery_india.pizza_names as pn join pizza_delivery_india.pizza_recipes pr 
on pn.pizza_id=pr.pizza_id
CROSS APPLY string_split(pt.toppings,',') AS split
join pizza_delivery_india.pizza_toppings as pt on pt.topping_id= TRY_CAST(Ltrim(split.value) as int)
group by pn.pizza_id
order by pn.pizza_name;
--19. What was the most commonly added extra (e.g., Mint Mayo, Corn)?
with cte as(
select po.order_id,pr.pizza_id,po.extras,unnest(string_to_array(po.extras,',')) as topping_id
from pizza_delivery_india.customer_orders po join pizza_delivery_india.pizza_recipes pr
on po.pizza_id=pr.pizza_id
where extras is not null and extras !=''
),
cte2 as(
	select cte.topping_id,topping_NAme,count(cte.topping_id  )as tt from pizza_delivery_india.pizza_toppings as pp,cte
	where CAST(cte.topping_id AS INT)= CAST(pp.topping_id AS INT)
	group by topping_name,cte.topping_id
	)
select cte2.topping_NAME, cte2.tt  from cte,cte2 
group by cte2.topping_NAme,cte2.tt
order by cte2.tt desc
limit 1
------other option 
--20. What was the most common exclusion (e.g., Cheese, Onions)?
with cte as(
select po.order_id,po.pizza_id,po.exclusions,unnest(string_to_array(po.exclusions,',')) as topping_id
from pizza_delivery_india.customer_orders po 
where exclusions is not null and exclusions !=''
),
cte2 as(
	select cte.topping_id,topping_NAme,count(cte.topping_id  )as tt from pizza_delivery_india.pizza_toppings as pp,cte
	where CAST(cte.topping_id AS INT)= CAST(pp.topping_id AS INT)
	group by topping_name,cte.topping_id
	)

select cte2.topping_NAME, cte2.tt  from cte,cte2 
group by cte2.topping_NAme,cte2.tt
order by cte2.tt desc
limit 1



--21. Generate an order item for each record in the `customer_orders` table in the format:

   -- * Paneer Tikka
   -- * Paneer Tikka - Exclude Corn
   -- * Paneer Tikka - Extra Cheese
   -- * Veggie Delight - Exclude Onions, Cheese - Extra Corn, Mushroomstopping_id
select * from pizza_delivery_india.pizza_toppings;

select * from pizza_delivery_india.riders ;
select * from pizza_delivery_india.customer_orders ;
select * from pizza_delivery_india.rider_orders;
select * from pizza_delivery_india.pizza_names;
select * from pizza_delivery_india.pizza_recipes;
select * from pizza_delivery_india.pizza_toppings;

select rd.order_id,concat(pn.pizza_name ,
	CASE
   	 WHEN rd.extras IS NOT NULL AND TRIM(rd.extras) != ''
        THEN '-Extra ' || string_Agg(es.t_name,',')
		else ''
	  end 
		,
      case WHEN rd.exclusions IS NOT NULL AND TRIM(rd.exclusions) != ''
        THEN '-Exclude ' ||  string_Agg(ex.t_name,',')
    	else  '' -- or use NULL or any default value if appropriate
	END
	) AS topping_label
		from row_d as rd
		left join extraa es on  rd.row_data=es.row_data
		left join exclu ex on  rd.row_data=ex.row_data
		left join pizza_delivery_india.pizza_names pn on rd.pizza_id=pn.pizza_id
	group by rd.row_data,rd.order_id,pn.pizza_name,rd.extras,rd.exclusions
	order by rd.order_id
	
drop table extraa;
drop table exclu;
drop table row_d;
create temp table row_d AS(
	select *,row_number()over(order by customer_id)AS row_data from pizza_delivery_india.customer_orders
	
)
select* from row_d
create temp table extraa AS(
with cte as(
	select *,row_number()over(order by customer_id)AS row_data from pizza_delivery_india.customer_orders 
),
cte1 as(
select row_data,unnest(string_to_array(extras,',')) as topping_id
from cte 
where extras is not null and extras !=''
)
select * from cte1;
, cte2 as(
	select row_data,string_AGG(pp.topping_name,',' ) as t_name from pizza_delivery_india.pizza_toppings as pp
	join cte1 on pp.topping_id=CAST(cte1.topping_id AS INT)	
	group by row_data
	)
	select * from cte2
)
select * from extraa
drop table exclu
create temp table exclu AS(
with cte as(
	select *,row_number()over(order by customer_id)AS row_data from pizza_delivery_india.customer_orders 
),
cte1 as(
select row_data,unnest(string_to_array(exclusions,',')) as topping_id
from cte 
where exclusions is not null and exclusions !=''
)
--select * from cte1;
, cte2 as(
	select row_data,string_AGG(pp.topping_name,',' )as t_name from pizza_delivery_india.pizza_toppings as pp
	join cte1 on pp.topping_id=CAST(cte1.topping_id AS INT)	
	group by row_data
	)
	select * from cte2
)

select * from exclu;
select * from extraa;

--22. Generate an alphabetically ordered, comma-separated ingredient list for each pizza order, using "2x" for duplicates.

    --* Example: "Paneer Tikka: 2xCheese, Corn, Mushrooms, Schezwan Sauce"
with c1 as(
select  co.order_id,co.pizza_id, pn.pizza_name, pr.toppings , co.extras, co.exclusions
from pizza_delivery_india.customer_orders co
left join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
left join pizza_delivery_india.pizza_recipes pr on co.pizza_id=pr.pizza_id 
),
--add all extras
c2 as(
	select order_id,pizza_name,cast(unnest(string_to_array(toppings,',')) as INT) as topping_id from c1  
				union all
	select order_id,pizza_name,cast(unnest(string_to_array(extras,','))as INT) as topping_id from c1 		
),
--select* from c2;
--remove exclusions
c3 as(
	select order_id,pizza_name,cast(unnest(string_to_array(exclusions,','))as INT) as topping_id from c1	
),

c4 as(
select c2.order_id,c2.pizza_name,c2.topping_id from c2 left join c3
on c2.order_id=c3.order_id and c2.topping_id=c3.topping_id
where c3.topping_id is null
),
--count
c5 as(
select order_id,pizza_name,topping_id,count(*)as topping_count from c4
group by order_id,pizza_name,topping_id
),
c6 as(
	select order_id,pizza_name,pt.topping_name,
	case when topping_count>1 then topping_count||'X'|| pt.topping_name
		else pt.topping_name
		End as result
	from c5
	join pizza_delivery_india.pizza_toppings pt on pt.topping_id=c5.topping_id

),
final_result AS (
    SELECT order_id,pizza_name,STRING_AGG(result, ','  order by result) AS topping_list
    FROM c6 GROUP BY order_id, pizza_name
)
SELECT 
    pizza_name || ': ' || topping_list AS result
FROM final_result
ORDER BY pizza_name;

--23. What is the total quantity of each topping used in all successfully delivered pizzas, sorted by most used first?
WITH delivered_orders AS (
    SELECT co.order_id, co.pizza_id, pr.toppings, co.extras, co.exclusions
    FROM pizza_delivery_india.customer_orders co
    JOIN pizza_delivery_india.rider_orders ro ON co.order_id = ro.order_id
	join  pizza_delivery_india.pizza_recipes pr on co.pizza_id=pr.pizza_id
    WHERE ro.pickup_time is not null
),
c2 as(
		select order_id,cast(unnest(string_to_array(toppings,',')) as INT) as topping_id from delivered_orders  
				union all
	select order_id,cast(unnest(string_to_array(extras,','))as INT) as topping_id from delivered_orders 		
 
),
--select * from c2;
--remove exclusions
c3 as(
	select order_id,cast(unnest(string_to_array(exclusions,','))as INT) as topping_id from delivered_orders	
),
c4 as(
select c2.order_id,c2.topping_id from c2 left join c3
on c2.order_id=c3.order_id and c2.topping_id=c3.topping_id
where c3.topping_id is null
)
--aggregate toppings using count 

select pt.topping_name, COUNT(*) AS total_quantity
FROM  c4 ft
JOIN pizza_delivery_india.pizza_toppings pt 
ON ft.topping_id = pt.topping_id
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;


--24. If a 'Paneer Tikka' pizza costs ₹300 and a 'Veggie Delight' costs ₹250 (no extra charges), how much revenue has Pizza Delivery India generated (excluding cancellations)?
with c as (
select co.pizza_id,
(case 
when co.pizza_id = 1 then 300 * count(co.pizza_id)
when co.pizza_id = 2 then 250 * count(co.pizza_id)
end) as revenue
from pizza_delivery_india.customer_orders co 
join pizza_delivery_india.rider_orders ro on co.order_id = ro.order_id
join pizza_delivery_india.pizza_names pn on co.pizza_id = pn.pizza_id
where ro.cancellation is null or ro.cancellation = ''
group by co.pizza_id
)
select pizza_id, revenue, sum(revenue) over() as total_revenue from c;

CHECK IT 
--25. What if there’s an additional ₹20 charge for each extra topping?
with cte1 as(
select co.order_id,co.pizza_id,co.customer_id,co.extras,
case when co.pizza_id=1 then 300 
	when co.pizza_id=2 then 250 
end as price,row_number() over(order by co.order_id) as rowNumber
from pizza_delivery_india.customer_orders co join pizza_delivery_india.rider_orders ro
on co.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation = ''

), cte2 as(
select order_id,pizza_id,customer_id,price,unnest(string_to_array(extras,','))as toppings,20 as extra_price,
row_number() over(order by order_id) as rowNumber
from cte1
order by order_id 
),
cte3 as(
select order_id,rownumber,extra_price,price,count(rownumber)as count_extras from cte2 group by rowNumber,order_id,extra_price,price
),
cte4 as(
select order_id,rownumber,count_extras,price,extra_price*count_extras as e_price from cte3
)
select cte1.order_id,cte1.customer_id,cte1.pizza_id,
	case when  cte1.rowNumber=cte4.rowNumber then cte1.price+e_price
			else cte1.price
			end as total
		 from cte1  full join cte4
	on cte1.rowNumber=cte4.rowNumber


--26. Cheese costs ₹20 extra — apply this specifically where Cheese is added as an extra.
with cte1 as(
select co.order_id,co.pizza_id,co.customer_id,co.extras,
case when co.pizza_id=1 then 300 
	when co.pizza_id=2 then 250 
end as price,row_number() over(order by co.order_id) as rowNumber
from pizza_delivery_india.customer_orders co join pizza_delivery_india.rider_orders ro
on co.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation = ''

), cte2 as(
select order_id,pizza_id,customer_id,price,cast(unnest(string_to_array(extras,',')) as INT)as toppings,20 as extra_price,
row_number() over(order by order_id) as rowNumber
from cte1 
order by order_id 
),
--select * from cte2;
cte3 as(
select order_id,rownumber,extra_price,price,count(rownumber)as count_extras from cte2  where toppings=4 group by rowNumber,order_id,extra_price,price

),
--select* from cte3
cte4 as(
select order_id,rownumber,count_extras,price,extra_price*count_extras as e_price from cte3
)
select cte1.order_id,cte1.customer_id,cte1.pizza_id,
	case when  cte1.rowNumber=cte4.rowNumber then cte1.price+e_price
			else cte1.price
			end as total
		 from cte1  full join cte4
	on cte1.rowNumber=cte4.rowNumber


--27. Design a new table for customer ratings of riders. Include:

    * rating_id, order_id, customer_id, rider_id, rating (1-5), comments (optional), rated_on (DATETIME)

    Example schema:

    ```sql
    CREATE TABLE pizza_delivery_india.rider_ratings (
      rating_id INT IDENTITY PRIMARY KEY,
      order_id INT,
      customer_id INT,
      rider_id INT,
      rating INT CHECK (rating BETWEEN 1 AND 5),
      comments NVARCHAR(255),
      rated_on DATETIME
    );
    ```

--28. Insert sample data into the ratings table for each successful delivery.

--29. Join data to show the following info for successful deliveries:

    * customer_id
    * order_id
    * rider_id
    * rating
    * order_time
    * pickup_time
    * Time difference between order and pickup (in minutes)
    * Delivery duration
    * Average speed (km/h)
    * Number of pizzas in the order

--30. If Paneer Tikka is ₹300, Veggie Delight ₹250, and each rider is paid ₹2.50/km, what is Pizza Delivery India's profit after paying riders?
With c as (
select co.pizza_id,
case 
when co.pizza_id = 1 then 300 * count(co.pizza_id)
when co.pizza_id = 2 then 250 * count(co.pizza_id)
end as revenue
from pizza_delivery_india.customer_orders  co 
join pizza_delivery_india.rider_orders ro on co.order_id = ro.order_id
join pizza_delivery_india.pizza_names pn on co.pizza_id = pn.pizza_id
where ro.cancellation is null or ro.cancellation = ''
group by co.pizza_id
),
c2 as(
select sum(Cast(Replace(distance, 'km', '') AS FLOAT)) * 2.50 as cost_per_rider from pizza_delivery_india.rider_orders
)
select (sum(c.revenue) - (select cost_per_rider from c2)) as net_profit
from c,c2


--31. If the owner wants to add a new “Supreme Indian Pizza” with all available toppings, how would the existing design support that? Provide an example `INSERT`:



-------to clear the data use patindex and charindes
-------------#STRING_SPLIT,CROSS APPLY,TRY_CAST,STRING_AGG,THE REUSLT IS A FLATTENED,NORMALIZED VersiON OF YOUR MAIN TablE


--extra 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [campaign_product](
	[campaign_id] [int] NULL,
	[product_id] [int] NULL
) ON [PRIMARY]
GO
INSERT INTO [campaign_product]
           ([campaign_id]
           ,[product_id])
     VALUES(1,1),(2,4),(3,6),(3,7),(3,8),(2,5),(1,2),(1,3)
GO








-- Create schema
CREATE database user_engagement;

GO
use user_engagement;

-- Table: event_identifier
CREATE TABLE event_identifier (
  [event_type] INT,
  [event_name] VARCHAR(13)
);

INSERT INTO event_identifier ([event_type], [event_name])
VALUES
  (1, 'Page View'),
  (2, 'Add to Cart'),
  (3, 'Purchase'),
  (4, 'Ad Impression'),
  (5, 'Ad Click');

-- Table: campaign_identifier
CREATE TABLE campaign_identifier (
  [campaign_id] INT,
  [products] VARCHAR(3),
  [campaign_name] VARCHAR(33),
  [start_date] DATETIME,
  [end_date] DATETIME
);

INSERT INTO campaign_identifier (
  [campaign_id], [products], [campaign_name], [start_date], [end_date]
)
VALUES
  (1, '1-3', 'BOGOF - Festival Deals', '2020-01-01', '2020-01-14'),
  (2, '4-5', '25% Off - Wedding Essentials', '2020-01-15', '2020-01-28'),
  (3, '6-8', 'Half Off - New Year Bonanza', '2020-02-01', '2020-03-31');


-- Table: page_hierarchy
CREATE TABLE page_hierarchy (
  [page_id] INT,
  [page_name] VARCHAR(30),
  [product_category] VARCHAR(20),
  [product_id] INT
);
select * from page_hierarchy;
INSERT INTO page_hierarchy (
  [page_id], [page_name], [product_category], [product_id]
)
VALUES
  (1, 'Home Page', NULL, NULL),
  (2, 'All Products', NULL, NULL),
  (3, 'Men’s Kurta Collection', 'Ethnic Wear', 1),
  (4, 'Sarees & Lehengas', 'Ethnic Wear', 2),
  (5, 'Casual Footwear', 'Footwear', 3),
  (6, 'Designer Handbags', 'Accessories', 4),
  (7, 'Gold Plated Jewelry', 'Accessories', 5),
  (8, 'Smartphones', 'Electronics', 6),
  (9, 'Laptops', 'Electronics', 7),
  (10, 'Kitchen Appliances', 'Home & Kitchen', 8),
  (11, 'Decor & Furnishings', 'Home & Kitchen', 9),
  (12, 'Checkout', NULL, NULL),
  (13, 'Confirmation', NULL, NULL);

 drop table dbo.users
-- Table: users
CREATE TABLE users (
  [user_id] INT,
  [cookie_id] VARCHAR(50),
  [start_date] DATETIME
);
--SELECT * FROM user_engagement.dbo.filecsv;

INSERT INTO users (user_id, cookie_id, start_date)
SELECT user_id, cookie_id, start_date
FROM dbo.filecsv;
select * from users;


drop table events;

CREATE TABLE events (
  "visit_id" VARCHAR(50),
  "cookie_id" VARCHAR(50),
  "page_id" INTEGER,
  "event_type" INTEGER,
  "sequence_number" INTEGER,
  "event_time" DATETIME
);

INSERT INTO events (visit_id,cookie_id,page_id,event_type,sequence_number,event_time)
SELECT visit_id,cookie_id,page_id,event_type,sequence_number,event_time
FROM dbo.User_engagment_events;
select * from EVENTS;
DELETE TOP (1)
FROM   EVENTS;

--# SET A
select * from users;
select * from event_identifier ;
select * from campaign_identifier;
select * from page_hierarchy;
select * from events;

--1. How many distinct users are in the dataset?
select count(distinct user_id) from users;
--2. What is the average number of cookie IDs per user?
SELECT AVG(C1) FROM (SELECT COUNT(COOKIE_ID) AS C1 FROM USERS GROUP BY USER_ID) AS CC
--3. What is the number of unique site visits by all users per month?
SELECT COUNT(DISTINCT VISIT_ID)AS NUMBER_OF_VISIT FROM USERS U JOIN EVENTS E ON U.COOKIE_ID=E.COOKIE_ID
GROUP BY MONTH(EVENT_TIME);
	
--4. What is the count of each event type?
SELECT COUNT(E.EVENT_TYPE) FROM event_identifier EI JOIN EVENTS E ON EI.EVENT_TYPE=E.EVENT_TYPE
GROUP BY E.EVENT_tYPE;
--5. What percentage of visits resulted in a purchase?
WITH C1 AS(
SELECT COUNT( DISTINCT VISIT_ID)AS V_ID FROM EVENTS 
),
C2 AS(
SELECT COUNT( DISTINCT VISIT_ID)AS VT_ID FROM EVENTS SELECT * FROM EVENTS WHERE EVENT_TYPE=3 
)
SELECT (CAST(C2.VT_ID AS FLOAT)/CAST(C1.V_ID AS FLOAT))*100 FROM C1,C2


--6. What percentage of visits reached checkout but not purchase?
WITH C1 AS(
SELECT COUNT(VISIT_ID)AS V_ID FROM EVENTS 
),
C2 AS(
SELECT COUNT(VISIT_ID)AS VT_ID FROM EVENTS E JOIN event_identifier EI ON E.EVENT_TYPE=EI.EVENT_TYPE 
WHERE EVENT_NAME !='PURCHASE' AND PAGE_ID=12
)
SELECT (CAST(C2.VT_ID AS FLOAT)/CAST(C1.V_ID AS FLOAT))*100 FROM C1,C2

--7. What are the top 3 most viewed pages?
select top(3)page_id,count(page_id)total from events where page_id not in(1,2)  group by page_id order by total desc;
--8. What are the views and add-to-cart counts per product category?
SELECT COUNT(CASE WHEN EVENT_TYPE IN(1,2)THEN 1 ELSE 0 END ) AS TOTAL,PRODUCT_CATEGORY 
FROM EVENTS AS E JOIN page_hierarchy AS PH
ON E.PAGE_ID=PH.PAGE_ID
WHERE PH.PAGE_ID nOT IN(1,2,12,13)
GROUP BY  product_category

------
SELECT COUNT(CASE WHEN EVENT_TYPE IN(1,2)THEN 1 ELSE 0 END ) AS TOTAL,PRODUCT_CATEGORY ,EVENT_TYPE
FROM EVENTS AS E JOIN page_hierarchy AS PH
ON E.PAGE_ID=PH.PAGE_ID
WHERE PH.PAGE_ID nOT IN(1,2,12,13)
GROUP BY  product_category,EVENT_TYPE


--9. What are the top 3 products by purchases?

WITH PURCHASE AS(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
)
SELECT TOP 3 PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM PURCHASE)
GROUP BY PAGE_NAME
ORDER BY COUNT(visit_id) DESC

--# SET B

--10. Create a product-level funnel table with views, cart adds, abandoned carts, and purchases.
--PURCHASE
WITH PURCHASE AS
(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C2 AS(
SELECT PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM PURCHASE)
GROUP BY PAGE_NAME
)
,
--ABANDONED
ABANDED AS
(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C3 AS(
SELECT PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id NOT IN (SELECT VISIT_ID FROM ABANDED)
GROUP BY PAGE_NAME
),
VIEW_AND_CARD AS(
select e.page_id,PH.PAGE_NAME,
		--e.event_Type,ei.event_name,S
		count(CASE WHEN e.event_type=1 THEN 1 END) AS VIEWS,
		count(CASE WHEN e.event_type=2 THEN 1 END) AS CARD_ADDS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where e.page_id not in(1,2)
			GROUP BY e.page_id,PH.PAGE_NAME
			
)	
SELECT VIEW_AND_CARD.page_id,VIEW_AND_CARD.PAGE_NAME,VIEWS,CARD_ADDS,C3.TOTAL AS abandoned_carts,C2.TOTAL AS PURCHASE
FROM C2 JOIN C3 ON C2.page_name =C3.page_name 
JOIN VIEW_AND_CARD ON C2.page_name =VIEW_AND_CARD.page_name 
ORDER BY page_id


--11. Create a category-level funnel table with the same metrics as above.

WITH PURCHASE AS
(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C2 AS(
SELECT PH.product_category ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM PURCHASE)
GROUP BY product_category
)
SELECT * FROM C2
--ABANDONED
ABANDED AS
(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C3 AS(
SELECT PH.product_category ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id NOT IN (SELECT VISIT_ID FROM ABANDED)
GROUP BY product_category
),
VIEW_AND_CARD AS(
select e.page_id,PH.product_category,
		--e.event_Type,ei.event_name,S
		count(CASE WHEN e.event_type=1 THEN 1 END) AS VIEWS,
		count(CASE WHEN e.event_type=2 THEN 1 END) AS CARD_ADDS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where e.page_id not in(1,2)
			GROUP BY e.page_id,PH.product_category
			
)	
SELECT VIEW_AND_CARD.page_id,VIEW_AND_CARD.product_category,VIEWS,CARD_ADDS,C3.TOTAL AS abandoned_carts,C2.TOTAL AS PURCHASE
FROM C2 JOIN C3 ON C2.product_category =C3.product_category 
JOIN VIEW_AND_CARD ON C2.product_category =VIEW_AND_CARD.product_category 
ORDER BY page_id

			
--12. Which product had the most views, cart adds, and purchases?
WITH C1 AS(
select e.page_id,PH.PAGE_NAME,
		e.event_Type,ei.event_name,
		count(CASE WHEN e.event_type=1 THEN 1 END) AS VIEWS,
		count(CASE WHEN e.event_type=2 THEN 1 END) AS CARD_ADDS
		--count(case when e.event_type=3 then 1 end) as purchase_count,
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where ph.product_id is not null
			GROUP BY e.page_id,PH.PAGE_NAME,e.event_Type,ei.event_name
),
--PURCHASE
PURCHASE AS(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
P AS(
SELECT  PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM PURCHASE)
GROUP BY PAGE_NAME
),
C2 AS(
	SELECT  PAGE_NAME AS V_PAGE_NAME FROM C1 WHERE VIEWS=(SELECT  MAX(VIEWS) AS MAXIMUM FROM C1)
	),
C3 AS(
	SELECT PAGE_NAME AS C_PAGE_NAME FROM C1 WHERE CARD_ADDS=(SELECT MAX(CARD_ADDS)AS MOST_CARD_ADDS  FROM C1)
	),
C4 AS(
	SELECT PAGE_NAME AS P_PAGE_NAME FROM P WHERE TOTAL=(SELECT MAX(TOTAL)AS MOST_PURCHASE_COUNT FROM P))

SELECT V_PAGE_NAME,C_PAGE_NAME,P_PAGE_NAME FROM C2,C3,C4


--13. Which product was most likely to be abandoned?
WITH PURCHASE AS(
SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
)
SELECT  TOP 1  PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id NOT IN (SELECT VISIT_ID FROM PURCHASE)
GROUP BY PAGE_NAME
ORDER BY COUNT(visit_id) DESC

--14. Which product had the highest view-to-purchase conversion rate?
WITH C1 AS(
	select e.page_id,PH.PAGE_NAME,
		count(CASE WHEN e.event_type=1 THEN 1 END) AS VIEWS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where product_category IS NOT NULL
			GROUP BY e.page_id,PH.PAGE_NAME
),
C2 AS(
	SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
	WHERE EVENT_TYPE=3	
),
C3 AS(SELECT PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
	WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM C2)
GROUP BY PAGE_NAME
)
SELECT  TOP 1 C1.PAGE_NAME,(CAST(TOTAL AS FLOAT)/CAST(VIEWS AS FLOAT))*100 AS RATE  FROM C1 JOIN C3 ON C1.page_name=C3.page_name
ORDER BY RATE DESC


# SET C.


--15. What is the average conversion rate from view to cart add?
WITH C1 AS(
	select e.page_id,PH.PAGE_NAME,
		count(CASE WHEN e.event_type=2 THEN 1 END) AS CARD_ADDS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where product_category IS NOT NULL
			GROUP BY e.page_id,PH.PAGE_NAME
),
C2 AS(
		select e.page_id,PH.PAGE_NAME,
		count(CASE WHEN e.event_type=1 THEN 1 END) AS VIEWS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where product_category IS NOT NULL
			GROUP BY e.page_id,PH.PAGE_NAME
		),
C3 AS(
SELECT   C1.PAGE_NAME,CAST(CARD_ADDS AS FLOAT)/CAST(VIEWS AS FLOAT)*100 AS RATE  FROM C1 JOIN C2 ON C1.page_name=C2.page_name
)
SELECT AVG(RATE) FROM C3;



--16. What is the average conversion rate from cart add to purchase?
WITH C1 AS(
	select e.page_id,PH.PAGE_NAME,
		count(CASE WHEN e.event_type=2 THEN 1 END) AS CARD_ADDS
			from event_identifier as ei
			join events as e on ei.event_Type=e.event_type
			join page_hierarchy as ph on ph.page_id=e.page_id
			where product_category IS NOT NULL
			GROUP BY e.page_id,PH.PAGE_NAME
),
C2 AS(
	SELECT DISTINCT E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
	WHERE EVENT_TYPE=3	
),
C3 AS(SELECT PH.page_name ,COUNT( DISTINCT visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
	WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM C2)
GROUP BY PAGE_NAME
),
C4 AS(
SELECT C1.PAGE_NAME,(CAST(TOTAL AS FLOAT)/CAST(CARD_ADDS AS FLOAT))*100 AS RATE  FROM C1 JOIN C3 ON C1.page_name=C3.page_name
)
SELECT AVG(RATE) FROM C4
;


--# SET C.

--17. Create a visit-level summary table with user_id, visit_id, visit start time, event counts, and campaign name.
WITH C1 AS(
SELECT E.VISIT_ID,U.USER_ID,MIN(E.event_time)AS START_TIME,COUNT(E.event_type)AS EVENT_COUNT
FROM users U JOIN EVENTS E ON U.cookie_id=E.cookie_id
GROUP BY VISIT_ID ,user_id
),
C2 AS(
SELECT e.VISIT_ID,
CASE WHEN PH.product_id  BETWEEN 1 AND 3  THEN 'BOGOF - Festival Deals'
	WHEN PH.product_id BETWEEN 4 AND 5 THEN '25% Off - Wedding Essentials'
	WHEN PH.product_id BETWEEN 6 AND 8 THEN 'Half Off - New Year Bonanza'
END AS CAMPAIGN_NAME
FROM events e join page_hierarchy PH on ph.page_id=e.page_id  WHERE ph.product_id IS NOT NULL
),
c3 as(
select visit_id,max(campaign_name) as campaign_name from c2 group by visit_id
)
select user_id,c1.visit_id,start_time,event_Count,campaign_name from c1 left join c3 on c1.visit_id=c3.visit_id

order by user_id
-------------------------------------------------
WITH C1 AS(
SELECT E.VISIT_ID,U.USER_ID,MIN(E.event_time)AS START_TIME,COUNT(E.event_type)AS EVENT_COUNT
FROM users U JOIN EVENTS E ON U.cookie_id=E.cookie_id
GROUP BY VISIT_ID ,user_id
),
c2 as(
select e.visit_id,ph.product_id from events e
 join page_hierarchy ph on ph.page_id=e.page_id where ph.product_id is not null
),
c3 as(
select cp.campaign_id,campaign_name,cp.product_id,start_date,end_date from campaign_identifier ci inner join campaign_product cp
on ci.campaign_id=cp.campaign_id  
),
c4 as(
select distinct user_id,c1.visit_id,campaign_name 
from c2 join c3 on c2.product_id=c3.product_id 
join c1 on c1.visit_id=c2.visit_id
where START_TIME between start_date and end_date
)
select  c1.user_id,c1.visit_id,START_TIME,EVENT_COUNT,campaign_name from c1 left join c4 
on c1.user_id=c4.user_id and c1.visit_id=c4.visit_id order by user_id,visit_id
;

--18. (Optional) Add a column for comma-separated cart products sorted by order of addition.

# Further Investigations
WITH C1 AS(
SELECT E.VISIT_ID,U.USER_ID,MIN(E.event_time)AS START_TIME,COUNT(E.event_type)AS EVENT_COUNT
FROM users U JOIN EVENTS E ON U.cookie_id=E.cookie_id
GROUP BY VISIT_ID ,user_id
),
c2 as(
select e.visit_id,ph.product_id,page_name from events e
 left join page_hierarchy ph on ph.page_id=e.page_id where ph.product_id is not null 
),
c3 as(
select cp.campaign_id,campaign_name,cp.product_id,start_date,end_date from campaign_identifier ci inner join campaign_product cp
on ci.campaign_id=cp.campaign_id  
),
c4 as(
select distinct user_id,c1.visit_id,campaign_name,string_agg(page_name,',') as cart_products
from c2 join c3 on c2.product_id=c3.product_id 
join c1 on c1.visit_id=c2.visit_id
where START_TIME between start_date and end_date
group by user_id,c1.visit_id,campaign_name
)
select  c1.user_id,c1.visit_id,START_TIME,EVENT_COUNT,campaign_name,cart_products from c1 left join c4 
on c1.user_id=c4.user_id and c1.visit_id=c4.visit_id order by user_id,visit_id



--19. Identify users exposed to campaign impressions and compare metrics with those who were not.
WITH C1 AS(
SELECT E.VISIT_ID,U.USER_ID,MIN(E.event_time)AS START_TIME,COUNT(E.event_type)AS EVENT_COUNT
FROM users U JOIN EVENTS E ON U.cookie_id=E.cookie_id
GROUP BY VISIT_ID ,user_id
),
c2 as(
select e.visit_id,ph.product_id from events e
 left join page_hierarchy ph on ph.page_id=e.page_id where ph.product_id is not null 
),
c3 as(
select cp.campaign_id,campaign_name,cp.product_id,start_date,end_date from campaign_identifier ci inner join campaign_product cp
on ci.campaign_id=cp.campaign_id  
),
c4 as(
select distinct user_id,c1.visit_id,campaign_name
from c2 join c3 on c2.product_id=c3.product_id 
join c1 on c1.visit_id=c2.visit_id
where START_TIME between start_date and end_date
group by user_id,c1.visit_id,campaign_name
),
c5 as(
select c1.USER_ID,c1.visit_id,event_count ,campaign_name,
		case when campaign_name is not null then 'exposed' else 'un_Exposed'
		end as compare from  c1 left join c4 
on c1.user_id=c4.user_id and c1.visit_id=c4.visit_id 
)
select compare,count( visit_id)as total_visit,count(distinct user_id)as total_user,sum(event_count)as total_count 
from c5 group by compare
;

--20. Does clicking on an impression lead to higher purchase rates?
WITH PURCHASE AS
(
SELECT  E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C2 AS(
SELECT COUNT(  visit_id)AS TOTAL from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=2
AND product_ID IS NOT NULL
AND visit_id IN (SELECT VISIT_ID FROM PURCHASE)
),
 AS
(
SELECT  E.VISIT_ID,PH.PRODUCT_CATEGORY ,event_type from events e  join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=3
),
C2 AS(
SELECT COUNT(  visit_id)AS TOTAL from events e -- join page_hierarchy ph on e.page_id=ph.page_id 
WHERE EVENT_TYPE=5 AND  visit_id IN (SELECT VISIT_ID FROM PURCHASE))
--AND product_ID IS NOT NULL AND 

SELECT * FROM C2

--21. What is the uplift in purchase rate for users who clicked an impression vs. those who didn’t?
--22. What metrics can be used to evaluate the success of each campaign?

WITH C1 AS(
SELECT E.VISIT_ID,U.USER_ID,MIN(E.event_time)AS START_TIME,COUNT(E.event_type)AS EVENT_COUNT
FROM users U JOIN EVENTS E ON U.cookie_id=E.cookie_id
GROUP BY VISIT_ID ,user_id
),
c2 as(
select e.visit_id,ph.product_id from events e
 left join page_hierarchy ph on ph.page_id=e.page_id where ph.product_id is not null 
),
c3 as(
select cp.campaign_id,campaign_name,cp.product_id,start_date,end_date from campaign_identifier ci inner join campaign_product cp
on ci.campaign_id=cp.campaign_id  
),
c4 as(
select distinct user_id,c1.visit_id,campaign_name
from c2 join c3 on c2.product_id=c3.product_id 
join c1 on c1.visit_id=c2.visit_id
where START_TIME between start_date and end_date
group by user_id,c1.visit_id,campaign_name
),
c5 as(
select c1.USER_ID,c1.visit_id,event_count ,campaign_name,
		case when campaign_name is not null then 'exposed' else 'un_Exposed'
		end as compare from  c1 left join c4 
on c1.user_id=c4.user_id and c1.visit_id=c4.visit_id where campaign_name is not null
)
select campaign_name,compare,count( visit_id)as total_visit,count(distinct user_id)as total_user,sum(event_count)as total_count 
from c5 group by compare,campaign_name
;
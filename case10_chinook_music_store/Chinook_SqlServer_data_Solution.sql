select * from Album;
select * from Artist;
select * from Customer;
select * from Employee;
select * from Genre;
select * from Invoice;
select * from InvoiceLine;
select * from MediaType;
select * from Playlist;
select * from PlaylistTrack;
select * from Track;

------Basic SQL (SELECT, WHERE, ORDER BY, LIMIT)---
--List all customers.
select *from customer;
--Show all tracks with their names and unit prices.
select TrackId,Name,UnitPrice from Track;
--List all employees in the sales department.
select * from Employee where title='Sales Support Agent';
--Retrieve all invoices from the year 2011.
select * from Invoice where InvoiceDate >2011/01/01;
--Show all albums by "AC/DC".
select * from Album al
	join Artist  ar on al.ArtistId=ar.ArtistId
	where Name='AC/DC';

--List tracks with a duration longer than 5 minutes.
with c1 as(
select trackId,name, milliseconds,((milliseconds/60000))as Minutes 
from Track )
select trackID,name,milliseconds,Minutes from c1 where Minutes>5;

--Get the list of customers from Canada.
select * from customer
where Country='Canada';

--List 10 most expensive tracks.
select top 10 TrackId,name,UnitPrice from track
order by UnitPrice desc;

--List employees who report to another employee.
SELECT * FROM Employee
WHERE ReportsTo IS NOT NULL AND ReportsTo != EmployeeId;

--Show the invoice date and total for invoice ID 5.
select invoiceId,invoicedate,total from Invoice
where InvoiceId=5;
-------------------------------------------------------------
--SQL Joins (INNER, LEFT, RIGHT, FULL)
--List all customers with their respective support representative's name.
select *,e.FirstName as Representative from Customer
left join Employee e on SupportRepId=EmployeeId;
--Get a list of all invoices along with the customer name.
select InvoiceId,InvoiceDate,i.CustomerId,FirstName + ' ' + LastName AS 'Customer_Name'
from Invoice i left join Customer c on i.CustomerId=c.CustomerId;

select * from Invoice;
--Show all tracks along with their album title and artist name.
select t.TrackId,t.Name,t.Composer,a.AlbumId,a.Title,ar.ArtistId,Ar.name from track t
left join album a on t.AlbumId=a.AlbumId
left join Artist ar on ar.ArtistId=a.ArtistId;
--List all playlists and the number of tracks in each.
select p.PlaylistID,count(t.TrackId)as number_of_TrackID ,p.name from Playlist p
left join  PlaylistTrack t on p.PlaylistId=t.PlaylistId
	group by p.PlaylistID,Name
--Get the name of all employees and their managers (self-join).
select e.EmployeeId,e.FirstName +' ' +e.LastName as 'ManagerNAme',em.FirstName +' ' +em.LastName as 'EmployeeNAme',e.Title
from Employee e right join Employee em 
on
e.employeeId=em.reportsto

--Show all invoices with customer name and billing country.
select InvoiceId,FirstName+' '+LastName as 'Customer Name',BillingCountry from Invoice i left join Customer c
on i.CustomerId=c.CustomerId;
--List tracks along with their genre and media type.
select  TrackId,t.Name,g.Name as Genre_Name,m.Name as Media_type from track t
left join Genre g on t.GenreId=g.GenreId
left join MediaType m on m.MediaTypeId=t.MediaTypeId;
--Get a list of albums and the number of tracks in each.
select a.AlbumId,Title,COUNT(TrackId)as number_of_track from Album a
left join Track t on a.AlbumId=t.AlbumId
group by a.AlbumId,title,TrackId,Name;
--List all artists with no albums.
with c1 as(
select ar.ArtistId,NAme,al.AlbumId,Title from Artist ar left join Album al
on ar.ArtistId=al.ArtistId
)
select * from c1 where AlbumId is null
--Find all customers who have never purchased anything.
select *  from Customer c
WHERE NOT EXISTS (
  SELECT * FROM Invoice i
  WHERE c.CustomerId = i.CustomerId
)
---------------------------------------------------------------------------------------------------------
					---Aggregations and Group By
--Count the number of customers in each country.
select count(CustomerId)Number_of_customer ,country from Customer
	group by Country
--Total invoice amount by each customer.
select i.CustomerId,c.Firstname+' '+c.Lastname as customerName,Sum(Total)as total_amount from Invoice i
left join Customer c on c.CustomerId=i.customerID
group by i.CustomerId,FirstName,LastName
--Average track duration per album.
select t.AlbumId,title ,concat(avg(Milliseconds/60000),' ','minutes')as avg_duration from track t
left join Album a on t.AlbumId=a.AlbumId
group by t.AlbumId,Title
order by t.AlbumId asc;
--Total number of tracks per genre.
select GenreID,Name,COUNT(TrackID)as total_number_of_tracks
from track group by GenreId,Name;

--Revenue generated per country.
select Country,sum(total) total_revenue from Customer c left join Invoice i
on c.CustomerId=i.CustomerId
group by Country;

--Average invoice total per billing city.
select BillingCity,round(avg(Total),2)as AVG_round_invoice  from Invoice
group by BillingCity
--Number of employees per title.
select count(e.EmployeeId) ,e.title
from Employee e left join Employee er
on e.EmployeeId=er.ReportsTo
group by e.title,e.EmployeeId

--Find the top 5 selling artists.
select top 5 ar.ArtistId, ar.Name as Artist,ROUND(SUM(i.UnitPrice*i.Quantity),2)as total_Sales from Artist ar
left join Album al on ar.ArtistId=al.ArtistId
left join track t on t.albumId= al.AlbumId
left join InvoiceLine i on i.TrackId=t.TrackId
--left join Invoice inv on inv.InvoiceId=i.InvoiceId
group by ar.ArtistId,ar.Name
order by total_sales desc
-----------------------------------------
with c1 as(
select al.AlbumId,al.artistId,ROUND(SUM(i.UnitPrice*i.Quantity),2)as total_Sales from album al 
join Track tr
on al.AlbumId=tr.AlbumId
left join InvoiceLine i on i.TrackId=tr.TrackId
group by al.AlbumId,al.ArtistId
)
select top 5 c1.artistID,albumId,total_Sales from c1 join Artist ar on
ar.ArtistId=c1.ArtistId
order by total_Sales desc

-----------------OR
--Number of playlists containing more than 10 tracks.
with c1 as(
select p.PlaylistID,count(t.TrackId)as number_of_TrackID ,p.name from Playlist p
left join  PlaylistTrack t on p.PlaylistId=t.PlaylistId
	group by p.PlaylistID,Name
	),
	c2 as(
	select PlaylistId,number_of_TrackID,name from c1
	where number_of_TrackID>10
	)
	select count(Playlistid)as Number_of_playlists from c2

--Top 3 customers by invoice total.
select top 3 i.CustomerId,FirstName +' '+lastName as 'CustomerName', sum(Total)as invoice_total from Invoice i
join Customer c on i.CustomerId=c.CustomerId
group by i.CustomerId,total,FirstName,LastName
order by invoice_total desc

--------------------------------------------------------------------------------------------------
-----------------------Subqueries (Scalar, Correlated, IN, EXISTS)
--Get customers who have spent more than the average.
select c.CustomerId,FirstName+' '+LastName as 'Customer_Name' ,total
	from Customer c left join Invoice i 
	on c.CustomerId=i.CustomerId where Total>(
		select avg(Total) as avg_total from Invoice i)

--List tracks that are more expensive than the average price.
select * from Track where UnitPrice > (select avg(UnitPrice) from Track)

--Get albums that have more than 10 tracks.
select 
	AlbumId,title,total from (select  tr.AlbumId,title,COUNT (TrackId)as total from track tr
	left join Album al on tr.AlbumId=al.AlbumId
	group by tr.AlbumId,title) as album_Count where total>10;



--Find artists with more than 1 album.
select ArtistId,name,total_album from 
(select al.ArtistId,name,count(AlbumId)as total_album from album al join Artist ar
on al.ArtistId=ar.ArtistId group by al.ArtistId,name )as album_count where total_album>1

--Get invoices that contain more than 5 line items.
select * from (select il.invoiceid,CustomerID,COUNT(il.InvoiceLineid)as total_invoiceline from 
				Invoice i left join InvoiceLine il on i.InvoiceId=il.InvoiceId 
				group by il.InvoiceId,CustomerId)as total_line
		where total_invoiceline>5
--Find tracks that do not belong to any playlist.
select t.TrackId,name from Track t left join PlaylistTrack p
	on t.TrackId=p.TrackId where p.TrackId not in (select TrackId from PlaylistTrack)
--List customers with invoices over $15.
select  * from (select c.customerId,firstName+ ' ' +lastname as 'customer_name',total as total_invoice
	from Invoice i left join Customer c on c.CustomerId=i.CustomerId
	)as customer_invoice
	where total_invoice >15

--Show customers who have purchased all genres.
select * from (select c.CustomerId,count(distinct(GenreId))as total  from Customer c left join Invoice i on
	c.customerId=i.customerID
	left join InvoiceLine il on i.InvoiceId=il.InvoiceId
	left join Track t on t.TrackId=il.TrackId
	group by c.CustomerId) as total_genre
	where total=(select count(distinct GenreId) as total from Track) 

--Find customers who haven’t bought from the 'Rock' genre.
 select * from (select c.CustomerId as c_id,t.GenreId,g.name from Customer c left join Invoice i on
	c.customerId=i.customerID
	left join InvoiceLine il on i.InvoiceId=il.InvoiceId
	left join Track t on t.TrackId=il.TrackId
	left join Genre g on g.GenreId=t.GenreId
	where g.Name !='Rock'
	)as sub_Rock left join Invoice on c_id=CustomerId
	where Invoice.CustomerId != c_id


--List tracks where unit price is greater than the average unit price of its media type.
select TrackId,Name,UnitPrice,MediaTypeId from Track t
where  exists (select 1 from Track  t1 
			group by MediaTypeId having t.MediaTypeId= t1.MediaTypeId
			and t.UnitPrice>avg(UnitPrice) )

		--Advanced Joins and Set Operations
--Get tracks in both 'Rock' and 'Jazz' playlists.
select T.NAME from track t join Genre g
on g.GenreId=t.GenreId   WHERE G.Name='Rock'
INTERSECT 
select T.NAME from track t join Genre g
on g.GenreId=t.GenreId   WHERE G.Name='Jazz'

--List all tracks that are in 'Pop' but not in 'Rock' playlists.
select  T.NAME from track t join Genre g
on g.GenreId=t.GenreId   WHERE G.Name='Pop'
except
select T.NAME from track t join Genre g
on g.GenreId=t.GenreId  where G.Name='Rock'

--Union customers from USA and Canada.
select * from Customer where Country='USA'
union 
select * from Customer where Country='Canada'

--Intersect customers from Canada and those who bought ‘AC/DC’ albums.
select CustomerId,FirstName,Country from Customer where Country='Canada'
intersect
select c.CustomerId,FirstName,Country from track t left join  Album a
on t.AlbumId=a.AlbumId left join Artist ar on  ar.ArtistId=a.AlbumId
left join InvoiceLine il on il.TrackId=t.TrackId
left join Invoice i on i.InvoiceId=il.InvoiceId
join Customer c on c.CustomerId=i.CustomerId
where ar.Name='AC/DC'

--Get artists that have albums but no tracks.
select AlbumId,ar.name from album al left join Artist ar
	on al.ArtistId=ar.ArtistId
except
select 
	al.AlbumId,ar.name from track t 
	left join  album al on t.albumId= al.AlbumId
	left join Artist ar on al.ArtistId=ar.ArtistId

--Find employees who are not assigned any customers.
SELECT EmployeeId FROM Employee
EXCEPT
SELECT SupportRepId FROM Customer
WHERE SupportRepId IS NOT NULL;
--where CustomerId is null 
--List invoices where total is greater than the sum of any other invoice.
select InvoiceId,CustomerId,Total from Invoice as i where 
	total> all(select Total from Invoice
				where i.InvoiceId <>InvoiceId )

--Get customers who have made more than 5 purchases using a correlated subquery.
SELECT CustomerId, FirstName, LastName FROM Customer c
WHERE (
    SELECT COUNT(*) FROM Invoice i
    WHERE i.CustomerId = c.CustomerId
) > 5;

--List tracks that appear in more than 2 playlists.
select TrackId,Name from Track t
where (select count(*) from PlaylistTrack p
		where p.TrackId=t.TrackId) >2;
--Show albums where all tracks are longer than 3 minutes.
select al.albumID,al.title from album al 
		where  not exists (
			select 1 from track t
			where al.AlbumId=t.albumId and Milliseconds/60000.0 <=3 
		);

		--using except
SELECT AlbumId, Title FROM Album
EXCEPT
SELECT al.AlbumId, al.Title FROM Album al
JOIN Track t ON al.AlbumId = t.AlbumId WHERE t.Milliseconds / 60000.0 <= 3;
------------------------------------------------------------------------------------------------


					--Window Functions
--Rank customers by total spending.
select i.CustomerID,sum(total)as summ,
	rank() over(order by sum(total) desc)as rank_customer
	from customer c join Invoice i on c.CustomerId=i.CustomerId
	group by i.CustomerId;

--Show top 3 selling genres per country.
with cte as(
select genreId,sum(total)total_Sum,country,rank()over(partition by country order by sum(total) desc)as rank_Countrywise
		from Customer c
			left join invoice i on c.CustomerId=i.CustomerId
			left join InvoiceLine il on i.InvoiceId=il.InvoiceId
			left join Track t on t.TrackId=il.TrackId
			group by GenreId,country 
	)
select GenreId,total_sum,Country,rank_Countrywise from cte where rank_Countrywise <4;

--Get running total of invoice amounts by customer.
select CustomerId,InvoiceId, total, sum(total)
	over( partition by customerid order by invoiceid asc
	rows between unbounded preceding and current row) running_total
		from invoice ;

--Find the invoice with the highest amount per customer.
with c1 as(
select invoiceID,customerId,total,
rank()over(partition by customerID order by total desc )as rk
	from Invoice
	)
select invoiceId,CustomerId,total from c1 where rk=1;

--Get the dense rank of employees by hire date.
select EmployeeId,LastName,FirstName,Title,HireDate,
		DENSE_RANK()over(order by hireDate desc)as dense_rank from employee;

--List tracks along with their rank based on unit price within each genre.


SELECT t.TrackId,t.Name AS TrackName,g.Name AS GenreName,
    t.UnitPrice,RANK() OVER (PARTITION BY t.GenreId ORDER BY t.UnitPrice DESC) AS Rank_Track
FROM Track t JOIN Genre g ON t.GenreId = g.GenreId;

--Compute average invoice total by country using window functions.
SELECT  c.Country, i.Total, AVG(i.Total) OVER (PARTITION BY c.Country) AS Avg_Invoice
FROM Invoice i
LEFT JOIN Customer c ON i.CustomerId = c.CustomerId;

--Show lag/lead of invoice totals per customer.
select c.CustomerId,FirstName+' '+LastName as 'CustomerName',total,
	lag(total)over(partition by i.customerId order by total asc)lag_total,
	lead(total)over(partition by i.customerId order by total asc)lead_total
	from invoice i left join Customer c
		on i.customerID=c.CustomerId

--List customers and their second highest invoice.
with c1 as(
select invoiceID,customerId,total,
rank()over(partition by customerID order by total desc )as rk
	from Invoice
	)
select invoiceId,CustomerId,total,rk from c1 where rk=2;

--Get the difference in invoice total from previous invoice for each customer.
with c1 as(
select invoiceID,total,customerId,lag(total)
		over( partition by customerid order by invoiceDate)as previous from invoice
		)
	select InvoiceId,CustomerId,total,(total-previous)as different from c1
	;
--CTEs and Recursive Queries
--List employees and their managers using recursive CTE.;
 with recursivecte as(
		select EmployeeId,CAST(FirstName + ' ' + LastName AS nvarchar(20)) AS EmployeeName,
		ReportsTo,cast(Null as nvarchar(20)) as ManagerName 
		from Employee WHERE ReportsTo IS NULL
		union all
		select  e.EmployeeId,CAST(e.FirstName + ' ' + LastName AS nvarchar(20)) AS EmployeeName, 
		e.ReportsTo ,r.EmployeeName as ManagerName
		from Employee e  join recursivecte r on e.ReportsTo=r.EmployeeId
)
select EmployeeID,EmployeeName,ManagerName from recursivecte;

--Use CTE to get top 3 customers by total spending.
with cte as(
	select i.CustomerId,FirstName,lastName,sum(Total)as total_spending from Customer c left join Invoice i
	on c.CustomerId=i.CustomerId
	group by i.CustomerId,FirstName,LastName
)
select top 3 CustomerID,FirstName,LastName,total_spending from cte
order by total_spending desc

--Create a CTE to list all invoice lines for albums by 'Metallica'.

with cte as(
select i.InvoiceId,il.InvoiceLineId,a.AlbumId,Title,ar.ArtistId,ar.Name from Invoice i 
	left join InvoiceLine il on i.InvoiceId=il.InvoiceId
	left join Track t on t.TrackId=il.TrackId
	left join Album a on a.AlbumId=t.AlbumId
	left join Artist ar on ar.ArtistId=a.ArtistId
)
select InvoiceId,InvoiceLineId,AlbumId,Title,ArtistId,Name from cte
where Name='Metallica';

--Use a CTE to show all tracks that appear in more than one playlist.
with c1 as(
select t.TrackId,Name,count(PlaylistId)as total_playlist from track t left join PlaylistTrack p
		on t.TrackId=p.TrackId
		group by t.TrackId,Name)
		select TrackID,NAme,total_playlist from c1 where total_playlist>1;

--Recursive CTE to list employee hierarchy (if > 2 levels).
with recursive_cte as(
	select employeeID,firstName,lastName,reportsTo from Employee
	union all
	select e.employeeID,e.firstName,lastName,reportsTo from Employee
	)
	select * from Employee

--CTE to get all albums with total track time > 30 minutes.
with cte as(
	select TrackId,Name,a.AlbumId,(Milliseconds/60000.0)as Minutes from track t left join Album a on 
	t.AlbumId=a.AlbumId
)
	select trackID,Name,AlbumID,Minutes from cte
	where minutes>30;

--Get top 5 albums by total revenue using CTE and window functions.
-- Get top 5 albums by total revenue using CTE and window functions
with cte  as(
select a.AlbumId,a.Title,sum(il.UnitPrice*il.Quantity)as total_revenue from album a
 join Track t on a.AlbumId=t.AlbumId
 join InvoiceLine il on t.TrackId=il.TrackId
group by a.AlbumId,a.Title
),
cte2 as(
		select *,rank() over(order by total_Revenue desc) as rankk
			from cte
	)

SELECT AlbumId,Title, total_revenue,rankk
FROM cte2
WHERE rankk <= 5;

--Use CTE to find average track price per genre and filter only those above global average.
with c1 as(
	select t.trackId,Name,GenreId,avg(i.UnitPrice * i.Quantity)as track_price from track t join InvoiceLine i
	on t.TrackId=i.TrackId
	group by GenreId,t.TrackId,t.Name
),
c2 as(
	select  avg(unitPrice*Quantity)t_price from InvoiceLine
)
select c1.TrackId,Name,GenreId,track_price,t_price from c1,c2
where track_price>t_price;

--CTE to find customers with the longest names.
with c1 as(
	select CustomerId,FirstName+' '+LastName as CustomerName from customer
),
c2 as(
select CustomerId,CustomerName,LEN(CustomerName)as length from c1
),
c3 as(
	select max(length) maximum  from c2
	)
	select CustomerId,CustomerName,maximum from c3 join c2 on c3.maximum=c2.length

--Create a CTE to rank all albums by number of tracks.
with c1 as(
	select count(TrackId)as number_of_track,a.AlbumID,a.title  from  track t join Album a
	on t.AlbumId=a.AlbumId
	group by a.AlbumId,title
),
c2 as(
select number_of_track,AlbumID,title,rank()over( order by number_of_track desc)as rk from c1
)
select * from c2
						--Advanced Analytics
--Get month-over-month revenue change.
select InvoiceDate from Invoice;
with c1 as(
select sum(total)as revenue,format(invoiceDate,'yyyy-MM')as Year_Month from invoice
	group by format(invoiceDate,'yyyy-MM')
	),
	c2 as(
		select lag(revenue) over(order by year_Month)as previous_Revenue,revenue,Year_Month from c1
	)
	select previous_Revenue,revenue,Year_Month,
	((revenue-previous_Revenue)/previous_Revenue)*100 as Month_Over_Month_value from c2;

--Calculate customer lifetime value.
with c1 as(
select customerID,avg(total)as avg_total_Value,count(invoiceDate)as purchase_freq,
		sum(total)as total_Value,DATEDIFF(Day,Min(invoiceDate),getDate()) as day_First_order
		from invoice
	group by CustomerId
	)
select CustomerId,avg_total_Value,purchase_freq,total_Value,day_First_order,
		round(avg_total_Value*purchase_freq*(day_First_order/365.0),2) as CLV from c1

--Get retention: how many customers returned for a second purchase?
with c1 as(
select CustomerID  from Invoice
	group by CustomerId
	having COUNT(InvoiceId)>1
	)
select COUNT(CustomerID)as total_Customer from invoice;

--Identify top selling track in each country.
with c1 as(
select InvoiceId ,Country,total,rank() over(partition by country order by total desc) as rk from Invoice i left join Customer c
	on i. CustomerId=c.CustomerId
	group by country,total,InvoiceID
	),
	c2 as(
	select c1.InvoiceId,Country,total,rk,TrackId from c1 left join InvoiceLine il 
	on c1.invoiceID=il.invoiceID 
	)
	select TrackId,Country,total,rk  from c2
	where rk=1
	
--Identify top selling track in each country.
with c1 as(
select Country,t.Name,sum(Quantity*t.UnitPrice)as total,
		row_number() over(partition by country order by sum(Quantity*t.UnitPrice) desc) as rk
	from Invoice i  join Customer c on i.CustomerId=c.CustomerId
	 join InvoiceLine il  on i.invoiceID=il.invoiceID 
	 join track t on t.TrackId=il.TrackId
	group by country,name
	)
	select * from c1
	where rk=1

--Show invoice trends by quarter.
with c1 as(
select count(InvoiceId) number_invoice,sum(total)as total_invoice ,
DATEPART(QUARTER,InvoiceDate)as quarters,year(InvoiceDate)as years from Invoice
group by InvoiceDate)
select count(number_invoice) as total_invoice, sum(total_invoice)as total,quarters,years from c1
group by years,quarters
;
--Count customers acquired per year.
select * from Invoice;

select count( distinct CustomerId)as number_of_customer,year(InvoiceDate)as acquired_year from Invoice
group by year(InvoiceDate);
WITH FirstPurchase AS (
    SELECT 
        c.CustomerId,
        YEAR(MIN(i.InvoiceDate)) AS AcquisitionYear
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
)
SELECT 
    AcquisitionYear,
    COUNT(*) AS CustomerCount
FROM FirstPurchase
GROUP BY AcquisitionYear
ORDER BY AcquisitionYear;



--Find churned customers (no purchases in last 12 months)
with c1 as(
select CustomerId,max(invoiceDate) as maximum_date from invoice
	group by CustomerId
)
select  * from c1
	where maximum_date <= DATEADD(month,-11,GETDATE()) ;

--Show most played tracks per user (using playlist track if usage data is simulated).
WITH track_count AS (
    SELECT c.CustomerId, t.TrackId,COUNT(*) AS play_count FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN PlaylistTrack pt ON t.TrackId = pt.TrackId
    GROUP BY c.CustomerId, t.TrackId
),
ranked_tracks AS (
    SELECT CustomerId, TrackId, play_count,RANK() OVER (PARTITION BY CustomerId ORDER BY play_count DESC) AS rnk FROM track_count
)
SELECT  CustomerId,TrackId, play_count,rnk FROM ranked_tracks WHERE rnk = 1 ORDER BY CustomerId;

--Simulate cohort analysis by signup month.


--Calculate total revenue per artist using joins and group by.
select ar.ArtistId,ar.name,sum(i.UnitPrice*Quantity)as total_revenue from track t join  Album a on t.AlbumId=a.AlbumId
		join Artist ar on ar.ArtistId=a.ArtistId
		join InvoiceLine i on i.TrackId=t.TrackId
		group by ar.ArtistId,ar.Name
		order by ArtistId
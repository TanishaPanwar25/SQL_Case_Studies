-- Movie Database Creation Script

-- 1. Create Database
CREATE DATABASE MovieDB;
--USE MovieDB;

-- 2. Movies Table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    release_year INT,
    rating FLOAT
);
select * from Movies;
-- Insert Data into Movies Table
INSERT INTO Movies (movie_id, title, genre, release_year, rating) VALUES
(1, 'Inception', 'Sci-Fi', 2010, 8.8),
(2, 'Titanic', 'Romance', 1997, 7.8),
(3, 'The Godfather', 'Crime', 1972, 9.2),
(4, 'The Dark Knight', 'Action', 2008, 9.0),
(5, 'Avatar', 'Sci-Fi', 2009, 7.9);

-- 3. Actors Table
CREATE TABLE Actors (
    actor_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_year INT,
    nationality VARCHAR(50)
);

-- Insert Data into Actors Table
INSERT INTO Actors (actor_id, name, birth_year, nationality) VALUES
(1, 'Leonardo DiCaprio', 1974, 'American'),
(2, 'Christian Bale', 1974, 'British'),
(3, 'Al Pacino', 1940, 'American'),
(4, 'Sam Worthington', 1976, 'Australian'),
(5, 'Morgan Freeman', 1937, 'American');

-- 4. MovieActors Table
CREATE TABLE MovieActors (
    movie_id INT,
    actor_id INT,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (actor_id) REFERENCES Actors(actor_id)
);

-- Insert Data into MovieActors Table
INSERT INTO MovieActors (movie_id, actor_id) VALUES
(1, 1), (1, 4), (2, 1), (3, 3), (4, 2), (4, 5), (5, 4);

-- 5. Reviews Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY,
    movie_id INT,
    critic_name VARCHAR(100),
    score FLOAT,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

-- Insert Data into Reviews Table
INSERT INTO Reviews (review_id, movie_id, critic_name, score) VALUES
(1, 1, 'Critic A', 9.0), (2, 2, 'Critic B', 8.0), (3, 3, 'Critic C', 9.5),
(4, 4, 'Critic D', 9.1), (5, 5, 'Critic E', 7.7);

-- 6. BoxOffice Table
CREATE TABLE BoxOffice (
    movie_id INT,
    domestic_gross BIGINT,
    international_gross BIGINT,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

-- Insert Data into BoxOffice Table
INSERT INTO BoxOffice (movie_id, domestic_gross, international_gross) VALUES
(1, 300000000, 500000000), (2, 600000000, 1500000000), (3, 250000000, 133000000),
(4, 530000000, 470000000), (5, 760000000, 2040000000);

-- Data Validation
SELECT * FROM Movies;
SELECT * FROM Actors;
SELECT * FROM MovieActors;
SELECT * FROM Reviews;
SELECT * FROM BoxOffice;
first_Check
--1. Which movies from each genre are considered the most critically acclaimed based on their ratings?
with Critically_acclaimed AS (
	select movie_id,Genre,rating , rank() over(partition by genre order by rating desc) As Ratings from Movies
)
select movie_id,genre,rating,Ratings from Critically_acclaimed where ratings=1
order by rating desc;

--2. Can you find the top 3 movies with the highest audience appreciation, regardless of genre?
with H as(
select movie_id,title,rating,  rank() over(order by rating desc) AS highest_Salary from Movies 
	)
	select * from H where highest_Salary<=3;
--3. Within each release year, which movies performed the best in terms of domestic revenue?
with Domestic_revenue As (
select 
	m.movie_id,m.title,m.release_year,b.domestic_gross, 
	RANK() OVER (PARTITION BY m.release_year ORDER BY b.domestic_gross DESC) AS revenue_rank
	from movies m join BoxOffice b
	on m.movie_id=b.movie_id
)
select movie_id,title,release_year,domestic_gross,revenue_rank from Domestic_revenue WHERE revenue_rank=1;
--4. Are there any movies within the same genre that have an equal standing when it comes to international box office collections?
with collections As (
select 
	m.movie_id,m.title,m.release_year,m.genre ,b.international_gross,
	count(*) OVER (PARTITION BY m.release_year , m.genre) AS same_genre
	from movies m join BoxOffice b
	on m.movie_id=b.movie_id
)
select movie_id,title, genre , international_gross from collections where same_genre>1;


--5. What are the best-rated movies in each genre according to critics?
with collections As (
select 
	m.movie_id,m.title,m.release_year,m.genre,r.critic_name,m.rating,
	rank() OVER (PARTITION BY m.genre order by m.rating desc) AS rating_rank
	from movies m join reviews r
	on m.movie_id=r.movie_id
)
select movie_id,title, genre ,critic_name,rating from collections where rating_rank=1;

--6. How can we divide the movies into four equal groups based on their domestic earnings?
with domestic_earning AS(
	select m.movie_id,b.domestic_gross,ntile(4) over(order by domestic_gross)
	from  movies m join BoxOffice b
	 on m.movie_id=b.movie_id
)
select * from domestic_earning;
--7. Can we group movies into three distinct categories according to their international revenue?
with internal_revenue AS(
select m.movie_id,b.international_gross,
	ntile(3) over(order by international_gross) AS revenue_international
	from movies m join BoxOffice b
	on m.movie_id=b.movie_id
)
select * from internal_revenue
--8. How would you classify movies based on how they rank in terms of audience rating?
select movie_id,title,rating , Rank() over( order by rating  desc)As Ratings from movies;
--9. If we split the actors based on the number of movies they've acted in, how many groups would we have if we only had two categories?
select m.movie_id,a.actor_id,
	count(m.movie_id) over(partition by a.actor_id ) AS splitactors
 from MovieActors m join Actors a on m.actor_id=a.actor_id;


--10. Can we divide the movies into ten segments based on their total box office performance?
select m.title,m.genre,b.movie_id,m.release_year,
ntile(10) over(order by domestic_gross+international_gross desc) 
from BoxOffice b join Movies  m on b.movie_id=m.movie_id;

--11. How would you determine the relative position of each movie based on its critic score?
select * from reviews;
select r.movie_id,m.title,rank() over( order by score desc) AS position from reviews r
join Movies m on r.movie_id=m.movie_id ;
--12. If we look at the movies within a specific genre, how would you find their relative success in terms of domestic box office collection?
select m.genre,b.domestic_gross, cume_dist() over(partition by genre order by domestic_gross) AS success
from  Movies m join BoxOffice b 
on m.movie_id=b.movie_id ;
--13. Considering the movies from the same year, can you identify how well each one did in terms of overall revenue?
select b.movie_id,m.title,m.release_year,rank() over(partition by release_year order by domestic_gross+international_gross desc)
from  BoxOffice b join Movies  m on b.movie_id=m.movie_id;
--14. How would you place actors on a timeline based on their birth years, 
--showing how they compare to one another.
/*with C as(
select distinct m.actor_id,a.name,a.birth_year,
	count(m.actor_id)over(partition by m.actor_id  order by ) as count_of_number
	from MovieActors m join actors a
	on m.actor_id=a.actor_id
	)
	select*,DENSE_RANK() over(order by count_of_number ) from C;*/
--15. What is the relative standing of each movie's rating within its genre?
select title,rating,
cume_dist() over(partition by genre order by rating ) AS relative_standing
from Movies;

--16. Can you determine how movies from the same genre compare to one another in terms of ratings?
select movie_id,title,genre ,rank() over(partition by genre order by rating) 
from movies;
--17. How do the movies from each release year compare to one another when we look at international revenue?
select b.movie_id,m.title,m.release_year,rank() over(partition by m.release_year order by b.international_gross)
from  BoxOffice b join Movies  m on b.movie_id=m.movie_id;
--18. Among all movies, how would you rate them based on the number of actors they feature?
with c as(
select m.title, count(ma.actor_id) over(partition by ma.movie_id) as count_of_actors
from MovieActors ma join Movies m
on ma.movie_id = m.movie_id)
select title, count_of_actors,
(case 
when count_of_actors = 1 then 2
else 3
end)
as rating
from c group by title, count_of_actors;
--19. Which critics tend to give higher ratings compared to others, and how do they rank?
select critic_name,rank() over(order by score desc) AS higher from reviews ; 
--20. How does each movie fare when cselect critic_name,score,movie_id,(case )omparing their total box office income to others?
with A As(
select title,domestic_gross+international_gross as total_fare from BoxOffice b join movies m 
	on m.movie_id=b.movie_id
)
select title,total_fare,rank() over(order by total_fare ) from A;
SELECT * FROM Movies;
SELECT * FROM Actors;
SELECT * FROM MovieActors;
SELECT * FROM Reviews;
SELECT * FROM BoxOffice;

--21. What are the differences in the way movies are ranked when you consider audience ratings versus the number of awards won?
--22. Can you list the movies that consistently rank high both in domestic gross and in audience appreciation?
--23. What would the movie list look like if we grouped them by their performance within their release year?
--24. Can we find the top movies from each genre, while also displaying how they compare in terms of critical reception and revenue distribution?
--25. If you were to group actors based on the number of movies they've been in, how would you categorize them?













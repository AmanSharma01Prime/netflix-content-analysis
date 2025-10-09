-- Netflix Content Analysis using SQL
-- Solutions of 15 business problems

--1. Find how many Movies vs TV Shows are in the dataset.

SELECT 
	show_type, 
	COUNT(*) AS num_of_titles
FROM netflix
GROUP BY show_type


--2. Trend of documentary added on netflix per year.


SELECT year_added, count(*) as Documentaries_count FROM
(
	SELECT
	*,
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
	FROM netflix
) AS table_1
WHERE 
	show_type = 'Movie'
	AND
	genre = 'Documentaries'
GROUP BY year_added


--3. Count the number of titles under each genre.

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS num_of_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC


--4. Find the most common rating for movies and TV shows

SELECT 
	show_type, 
	no_of_times_rating_given, 
	rating 
FROM
(
SELECT
	show_type,
	rating,
	COUNT(*) AS no_of_times_rating_given,
	RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1, 2
) 
AS table_1
WHERE ranking = 1


--5. Identify top 10 countries producing the highest number of Netflix titles.


SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS all_countries,
	COUNT(title) AS num_of_titles
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


--6. Find top 10 directors with the highest number of titles.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS all_directors,
	COUNT(title) AS num_of_titles
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


--7.  Find the top 10 actors who have appeared in the highest number of movies produced in India.


SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(show_id) AS num_of_movies
FROM netflix
WHERE country ~* '\mindia?\M' AND show_type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


--8. Identify the longest duration movie and the TV show with the most seasons.


WITH longest_movie AS
(
	SELECT 
		show_type,
		title,
		duration
	FROM netflix
	WHERE show_type = 'Movie' AND duration_type = 'min'
	ORDER BY duration_num DESC
	LIMIT 1
),
 longest_tv_show AS
(
	SELECT 
		show_type,
		title,
		duration
	FROM netflix
	WHERE show_type = 'Tv Show' AND duration_type = 'seasons'
	ORDER BY duration_num DESC
	LIMIT 1
)
SELECT * FROM longest_movie UNION ALL SELECT * FROM longest_tv_show



--09. count titles contains words 'love', 'action', 'violence'

SELECT	
	COUNT(*) AS content_with_keywords 
FROM netflix
WHERE 
	description ~* '\mlove\M' OR description ~* '\maction\M' OR description ~* 'violence'


--10. Find each year and the average numbers of content release in India on netflix. 
    --return top 5 year with highest avg content release!


SELECT
	year_added,
	COUNT(*) AS content_added_per_year,
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::numeric * 100, 2) AS avg_content	
FROM netflix
WHERE country ~* '\mindia?\M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


--11. Distribution of release duration for movies and seasons for TV shows

SELECT show_type,  
       COUNT(*) AS total_titles,
       ROUND(AVG(duration_num), 2 ) AS avg_duration,
	   duration_type,
       MIN(duration_num) AS min_duration,
       MAX(duration_num) AS max_duration
FROM netflix
WHERE duration_type IS NOT NULL
GROUP BY show_type, duration_type;


--12-A. count titles added on netflix per year (2015-2021)

SELECT 
	year_added,
	COUNT(*) AS content_count
FROM netflix
WHERE year_added BETWEEN 2015 AND 2021
GROUP BY 1
ORDER BY 1

--12-B. Compare growth of Movies vs TV Shows over time

SELECT 
	year_added, 
	show_type, 
	COUNT(*) AS total_titles
FROM netflix
WHERE year_added >= 2010
GROUP BY year_added, show_type
ORDER BY year_added, show_type;


--13. Root cause analysis: Investigate TV show surge post-2015

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS All_countries,
	count(*) as tv_show_count,
	year_added
FROM netflix
WHERE 
	show_type='Tv Show' AND year_added >= 2015
GROUP BY 
	year_added, 
	All_countries
ORDER BY 
	year_added DESC, 
	tv_show_count DESC;


--14. Categorize content based on keywords 'kill' and 'violence' in description. Label content as 'Bad' and all other 
--    as 'Good'. Count how many items fall into each category.


WITH cat_table AS 
(
SELECT	
	*,
	CASE WHEN description ~* '\mkill(s|ed|ing|er|ers)?\M' OR description ILIKE '% violen%'
		THEN 'Bad Content'
		ELSE 'Good Content'
		END AS content_category
FROM netflix
)
SELECT content_category, COUNT(*) AS total_content
FROM cat_table
GROUP BY content_category


--15. Top 3 genres by top 5 countries – regional preference analysis


WITH genre_split AS (
    SELECT 
        TRIM(g) AS genre,
        TRIM(c) AS country
    FROM netflix
    CROSS JOIN UNNEST(STRING_TO_ARRAY(listed_in, ',')) g
    CROSS JOIN UNNEST(STRING_TO_ARRAY(country, ',')) c
    WHERE country IS NOT NULL 
      AND TRIM(c) <> ''
      AND TRIM(g) <> ''
),
country_totals AS (
    SELECT 
        country, 
        COUNT(*) AS total_titles
    FROM genre_split
    GROUP BY country
    ORDER BY total_titles DESC
    LIMIT 5
),
genre_count AS (
    SELECT 
        gs.country, 
        gs.genre, 
        COUNT(*) AS genre_titles,
        ROW_NUMBER() OVER (
            PARTITION BY gs.country 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM genre_split gs
    JOIN country_totals ct 
      ON gs.country = ct.country
    GROUP BY gs.country, gs.genre
)
SELECT gc.country, gc.genre, gc.genre_titles
FROM genre_count gc
JOIN country_totals ct ON gc.country = ct.country
WHERE rn <= 3
ORDER BY ct.total_titles DESC, gc.country, gc.genre_titles DESC;


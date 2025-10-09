# Netflix Content Analysis Using SQL, Python (Pandas/Colab), and Google Sheets

<!-- ![netflix logo]()  -->

<p align="center">
  <img src="https://github.com/AmanSharma01Prime/netflix-content-analysis/blob/main/assets/netflix%20logo.jpeg" alt="Banner" width="600" height="350"/>
</p>


## Overview

This project provides an end-to-end analysis of Netflix’s content catalog. It combines **data cleaning and exploration in Python (Colab)**, **SQL-based analysis of business problems**, **visualizations in Google Sheets**, and **insights summarized in a document and Slides/PDF deck**.  

The analysis covers:  
- Content trends over time, including annual releases and documentary growth  
- Genre distribution and country-wise preferences  
- Ratings distribution and root cause analysis for movies and TV shows  
- Keyword-based thematic exploration and top contributors (directors/actors)  

The goal is to showcase **practical data analysis skills**, including data cleaning, SQL querying, visualization, and insight generation, while deriving actionable findings from a real-world dataset.


## Objectives

- Explore content distribution across types, genres, countries, and time periods.
- Identify trends in content additions and user-targeted characteristics (ratings, duration).
- Highlight top-performing contributors (directors, actors).
- Analyze content themes and regional preferences to support business decision-making.
- Summarize SQL results into actionable insights and visualizations.


## 📊 Project Workflow

1. Performed initial exploration in Colab to understand and clean the dataset.  
2. Designed database schema (`Schema.sql`) and imported cleaned data into SQL.  
3. Defined business problems (`business problems.sql`) and solved them (`business solutions.sql`).  
4. Used SQL results to create charts in Google Sheets.  
5. Summarized findings in an Insights Document and Visualization Deck (Slides/PDF).  


## 📂 Files in This Repository

- [Schema.sql](sql/Schema.sql) → Database schema creation.
- [business problems.sql](sql/business_problems.sql) → Defined business questions.
- [business solutions.sql](sql/business_solutions.sql) → SQL queries with solutions.
- [netflix_titles.csv](data/netflix_titles.csv) → Dataset used for analysis.
- [netflix_dataset_cleaning.ipynb](notebooks/netflix_dataset_cleaning.ipynb) → Exploratory Data Analysis (EDA) - colab notebook.
- [netflix analysis slides.pdf](reports/netflix_analysis_slides.pdf) → Backup of visualization deck (all charts + short insights).
- [Netflix Analysis - Insights Document.pdf](reports/Netflix_Analysis_Insights_Document.pdf) → Backup of insights document.
- [README.md](README.md) → Project overview and documentation.

### 🔗 External Links
- [Google Sheets – Interactive Charts](https://docs.google.com/spreadsheets/d/1Q4iAqJ6-Evj9Q3JH97RpZt36Ohn8JRU3iEdFpcPUALI/edit?usp=sharing)
- [Google Slides – Visualization Deck](https://docs.google.com/presentation/d/19UJPGIc3eAdQVVivCMvHYIavOQLJk-TzLGksyrZlmOA/edit?usp=sharing)
- [Insights Document](https://docs.google.com/document/d/1RTb9ov4vMU_2TfvgzEyW-9y4QsYrhPwjOhxMMjYmkLA/edit?usp=sharing)
  

## 📊 Visualizations (Highlights)

Here are a few key charts from the analysis.  
Full interactive charts are available in the [Google Sheets link](https://docs.google.com/spreadsheets/d/1Q4iAqJ6-Evj9Q3JH97RpZt36Ohn8JRU3iEdFpcPUALI/edit?usp=sharing), and a complete visual deck is in the [Google Slides link](https://docs.google.com/presentation/d/19UJPGIc3eAdQVVivCMvHYIavOQLJk-TzLGksyrZlmOA/edit?usp=sharing). (slides [pdf](reports/netflix_analysis_slides.pdf))

### Key Charts

1. **Content Distribution**  
   ![Content Distribution](visualisations/content_distribution.png)  
   *Pie chart showing total movies vs TV shows.*

2. **Genre Distribution**  
   ![Genre Distribution](visualisations/genre_distribution.png)  
   *Top genres across all titles.*

3. **Regional Genre Preferences**  
   ![Regional Genre Preferences](visualisations/regional_genre_preferences.png)  
   *Top 3 genres by top 5 countries.*


## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql

CREATE TABLE netflix
(
		show_id			   VARCHAR(10),
		show_type		   VARCHAR(10),
		title			   VARCHAR(150),
		director		   VARCHAR(250),
		casts			   VARCHAR(800),
		country			   VARCHAR(150),
		date_added		   DATE,
		release_year	   INT,	
		rating			   VARCHAR(10),
		duration		   VARCHAR(15),
		listed_in		   VARCHAR(100),
		description		   VARCHAR(300),
		duration_num	   INT,
		duration_type	   VARCHAR(10),
		year_added		   INT
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows in the dataset.

```sql
SELECT 
	show_type, 
	COUNT(*) AS num_of_titles
FROM netflix
GROUP BY show_type
```

> **Objective:** Determine the distribution of content types on Netflix to understand platform composition. 

### 2. Trend of documentary added on netflix per year.

```sql
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

```

> **Objective:** Analyze yearly trends in documentary releases to identify content growth patterns. 


### 3. Count the number of titles under each genre.

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS num_of_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
```

> **Objective:** Understand genre popularity by counting titles in each category.


### 4. Find the most common rating for movies and TV shows.

```sql
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
```

> **Objective:** Identify the prevalent content ratings to assess audience targeting.

### 5. Identify top 10 countries producing the highest number of Netflix titles.

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS all_countries,
	COUNT(title) AS num_of_titles
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

```

> **Objective:** Highlight the most prolific content-producing countries on Netflix.

### 6. Find top 10 directors with the highest number of titles.

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS all_directors,
	COUNT(title) AS num_of_titles
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```

> **Objective:** Determine which directors contribute most to Netflix’s catalog.

### 7. Find the top 10 actors who have appeared in the highest number of movies produced in India.

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(show_id) AS num_of_movies
FROM netflix
WHERE country ~* '\mindia?\M' AND show_type = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```

> **Objective:** Identify the most featured actors in Indian Netflix movies.

### 8. Identify the longest duration movie and the TV show with the most seasons.

```sql
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

```

> **Objective:** Highlight extreme cases in content duration for movies and TV shows.

### 9. Count titles contains words 'love', 'action', 'violence'.

```sql
SELECT	
	COUNT(*) AS content_with_keywords 
FROM netflix
WHERE 
	description ~* '\mlove\M' OR description ~* '\maction\M' OR description ~* 'violence'

```

> **Objective:** Analyze the prevalence of specific themes across Netflix titles.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT
	year_added,
	COUNT(*) AS content_added_per_year,
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::numeric * 100, 2) AS avg_content	
FROM netflix
WHERE country ~* '\mindia?\M'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

> **Objective:** Identify peak years for Netflix content addition in India.

### 11. Distribution of release duration for movies and seasons for TV shows.

```sql
SELECT show_type,  
       COUNT(*) AS total_titles,
       ROUND(AVG(duration_num), 2 ) AS avg_duration,
	   duration_type,
       MIN(duration_num) AS min_duration,
       MAX(duration_num) AS max_duration
FROM netflix
WHERE duration_type IS NOT NULL
GROUP BY show_type, duration_type;
```

> **Objective:** Explore content length patterns to understand audience engagement trends.

### 12.(a) Count titles added on netflix per year (2015-2021).

```sql
SELECT 
	year_added,
	COUNT(*) AS content_count
FROM netflix
WHERE year_added BETWEEN 2015 AND 2021
GROUP BY 1
ORDER BY 1
```

> **Objective:** Examine the yearly growth in Netflix content additions over time.

### 12.(b) Compare growth of Movies vs TV Shows over time.

```sql
SELECT 
	year_added, 
	show_type, 
	COUNT(*) AS total_titles
FROM netflix
WHERE year_added >= 2010
GROUP BY year_added, show_type
ORDER BY year_added, show_type;
```

> **Objective:** Track and compare the growth trends of Movies and TV Shows separately.

### 13. Root cause analysis: Investigate TV show surge post-2015.

```sql
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
```

> **Objective:** Identify factors contributing to the increase in TV shows after 2015.

### 14. Categorize content based on keywords 'kill' and 'violence' in description. Label content as 'Bad' and all other as 'Good'. 
Count how many items fall into each category.

```sql
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

```

> **Objective:** Classify content to analyze the distribution of potentially violent vs general titles.

### 15. Top 3 genres by top 5 countries – regional preference analysis.

```sql
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
```

> **Objective:** Determine regional genre preferences by analyzing top genres per country.

## Findings and Conclusion

- **Content Distribution:** Analysis of Movies vs TV Shows, genres, and ratings reveals the diversity of Netflix’s catalog.
- **Top Contributors:** Identifying leading directors, actors, and countries highlights where most content originates and who drives production.
- **Trends Over Time:** Yearly content additions and growth comparisons between Movies and TV Shows show how Netflix expanded its library over time, with a notable surge in TV shows post-2015.
- **Content Characteristics & Themes:** Examining duration, seasons, and keyword-based classification (“Good” vs “Bad”) provides insight into the nature and themes of the content.
- **Regional Preferences:** Top genres by country reveal viewer preferences and regional content patterns.
  
This analysis provides a structured understanding of Netflix’s content library, offering actionable insights that can support content strategy, platform growth, and regional targeting. These insights are ready for further exploration and visualization using Google Sheets or Excel.


## Author - Aman Sharma

This project is part of my portfolio and primarily showcases SQL skills that are essential for a data analyst role.  

Alongside SQL, it also demonstrates supporting steps such as *data exploration*, *visualization*, and *reporting of insights* - reflecting the   
*end-to-end analysis* process.


### Let’s Connect

If you have any questions, feedback, or opportunities to collaborate, feel free to reach out:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/amansharma01prime/)
- **GitHub**: [Explore my projects and code](https://github.com/AmanSharma01Prime)

If you found this project insightful, consider ⭐ starring the repo - it helps others discover it too.

Thank you for visiting!

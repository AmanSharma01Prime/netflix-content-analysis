# Netflix Content Analysis using Python, SQL and Sheets

<!-- ![netflix logo](https://github.com/AmanSharma01Prime/netflix-content-analysis/blob/main/netflix-logo-in-clouds-2.jpeg)  -->

<p align="center">
  <img src="https://github.com/AmanSharma01Prime/netflix-content-analysis/blob/main/netflix-logo.jpeg" alt="Banner" width="900" height="450"/>
</p>


## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### Section 1 – Dataset Overview
*Purpose: Introduce dataset and basic exploration.*

#### 1. Movies vs TV Shows
**Description:** Count how many Movies vs TV Shows are in the dataset.  
**SQL Concepts / Tags:** `COUNT`, `GROUP BY`

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Aman Sharma

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on Github and Linkedin:

- **YouTube**: [Subscribe to my channel for tutorials and insights](https://www.youtube.com/@zero_analyst)
- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/zero_analyst/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)
- **Discord**: [Join our community to learn and grow together](https://discord.gg/36h5f2Z5PK)

Thank you for your support, and I look forward to connecting with you!













========================================================================================================
## Objective

- find total number of movies and tv shows on netflix
- find which country has most movies on netflix
- find most watched content on netflix acc to country

## Netflix Dataset – 15 SQL Problems

### Section 1 – Dataset Overview (Basic Intro)

Purpose: Introduce dataset and basic exploration.

1. Movies vs TV Shows – Count how many Movies vs TV Shows are in the dataset.

SQL Skills: COUNT, GROUP BY


2. Titles with “love” in Description – Find all titles where the description contains the word “love”.

SQL Skills: LIKE, text search

3. Movies that are Documentaries – List all Movies categorized as Documentaries.

SQL Skills: WHERE, LIKE, filtering

4. Oldest Release Year Titles – Find the oldest release year title(s) available.

SQL Skills: MIN(), filtering, ORDER BY

### Section 2 – Descriptive Insights (Distribution & Top Entities)

Purpose: Identify patterns in content types, genres, actors, and directors.

5. Genre / Category Distribution – Count the number of titles under each genre/category in listed_in.

SQL Skills: COUNT, GROUP BY

6. Top 5 Genres by Number of Titles – Identify which genres have the most content.

SQL Skills: COUNT, GROUP BY, ORDER BY, LIMIT

7. Most Common Ratings – Find the most frequent rating for Movies and TV Shows.

SQL Skills: COUNT, GROUP BY, ORDER BY, LIMIT

8. Top 5 Directors – Find directors with the highest number of titles.

SQL Skills: COUNT, GROUP BY, ORDER BY, LIMIT

9. Top 10 Actors (Global) – Identify actors who appear most frequently in Netflix titles.

SQL Skills: COUNT, GROUP BY, ORDER BY, LIMIT, text parsing if multiple actors in one field

10. Director Spotlight – Fun Query – List all titles by a popular/fun director (e.g., David Dhawan).

SQL Skills: WHERE, filtering, LIKE

### Section 3 – Trend & Market Analysis

Purpose: Analyze time trends and geographical insights.

Content Growth Trend (Yearly) – Show how many titles were added to Netflix each year.

SQL Skills: EXTRACT(YEAR FROM date_added), COUNT, GROUP BY, ORDER BY

Trend in Indian Releases – Find each year’s average number of content releases in India; return top 5 years.

SQL Skills: AVG(), GROUP BY, ORDER BY, filtering

Top 5 Countries with Most Titles – Identify countries producing the highest number of Netflix titles.

SQL Skills: COUNT, GROUP BY, ORDER BY, LIMIT

### Section 4 – Deeper Business & Data Insights

Purpose: Highlight advanced/insightful queries and actionable analysis.

Longest Movie & TV Show with Highest Seasons – Identify the longest duration movie and the TV show with the most seasons.

SQL Skills: MAX(), filtering, ORDER BY, conditional logic

Content Risk Categorization – Classify content as “Bad” if description contains keywords like “kill” or “violence”, otherwise “Good”, then count.

SQL Skills: CASE WHEN, LIKE, COUNT, text search

Titles Without Directors (Data Quality Check) – Find all titles missing director information.

SQL Skills: IS NULL, filtering

--schema for netflix

CREATE TABLE netflix
(
		show_id			VARCHAR(10),
		show_type		VARCHAR(10),
		title			VARCHAR(150),
		director		VARCHAR(250),
		casts			VARCHAR(800),
		country			VARCHAR(150),
		date_added		DATE,
		release_year	INT,	
		rating			VARCHAR(10),
		duration		VARCHAR(15),
		listed_in		VARCHAR(100),
		description		VARCHAR(300),
		duration_num	INT,
		duration_type	VARCHAR(10),
		year_added		INT,
		month_added		INT

);

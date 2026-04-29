/* --------------------- FUNCTIONS BY DATA TYPE --------------------- */
----------------------------- 1. NUMERIC FUNCTIONS ------------------------------ 
-- They can be applied to numeric columns (integer, decimal, etc) 

-- Apply a log transformation (base 10) to the population of a country
SELECT  country, population,
		ROUND(LOG(population, 10), 2) AS log_pop
FROM country_stats;


-- Pro tip: FLOOR function for binning
WITH pm AS
		(SELECT  country, population,
				FLOOR(population/1000000) AS pop_m -- scale by a million
		FROM country_stats)
SELECT pop_m, COUNT(country) AS num_countries
FROM pm
GROUP BY pop_m
ORDER BY pop_m
;


-- Max of a column vs max of a row: Least and greatest functions

-- Create a miles run table
CREATE TABLE miles_run (
    name VARCHAR(50),
    q1 INT,
    q2 INT,
    q3 INT,
    q4 INT
);

INSERT INTO miles_run (name, q1, q2, q3, q4) VALUES
	('Ali', 100, 200, 150, NULL),
	('Bolt', 350, 400, 380, 300),
	('Jordan', 200, 250, 300, 320);

SELECT * FROM miles_run;

--Return the greatest value for each column
SELECT MAX(q1), MAX(q2), MAX(q3), MAX(q4)
FROM miles_run;

-- Return the greatest value for each row
SELECT GREATEST(q1, q2, q3, q4) AS most_miles
FROM miles_run;

-- Return the greatest value for each row with no null value
SELECT GREATEST(q1, q2, q3, COALESCE(q4,0)) AS most_miles
FROM miles_run;


----------------------------- 2. CAST & CONVERT FUNCTIONS ------------------------------
-- Use them to convert data from one data type to another (not for all data type conversions)
-- They change the data type of the column only for the duration of the query, not permanently

-- Create a sample table
CREATE TABLE sample_table (
    id INT,
    str_value CHAR(50)
);

INSERT INTO sample_table (id, str_value) VALUES
	(1, '100.2'),
	(2, '200.4'),
	(3, '300.6');

SELECT * FROM sample_table;

-- Turn a string to a decimal
SELECT id, CAST(str_value AS FLOAT) * 2 AS float_col
FROM sample_table;

-- Turn an integer into a float
SELECT country, population/5.0 pop_float
FROM country_stats;

-- How many customers have spent $0-10, $10-20, and so on for every $10 range
WITH purchase_info AS (
    SELECT
        o.customer_id,
        SUM(o.units * p.unit_price) AS total_spend
    FROM orders o
    LEFT JOIN products p
        ON o.product_id = p.product_id
    GROUP BY o.customer_id
),
spend_ranges AS (
    SELECT
        customer_id,
        FLOOR(total_spend / 10) * 10 AS spend_range_start
    FROM purchase_info
)
SELECT
    CONCAT('$', spend_range_start, '-$', spend_range_start + 10) AS spend_range,
    COUNT(*) AS number_of_customers
FROM spend_ranges
GROUP BY spend_range_start
ORDER BY spend_range_start;


----------------------------- 3. DATETIME FUNCTIONS ------------------------------
-- They can be applied to datetime columns (date, time)

-- Get the current date and time
SELECT CURRENT_DATE, CURRENT_TIMESTAMP;

-- Create events table
CREATE TABLE my_events (
    event_name      VARCHAR(50),
    event_date      DATE,
    event_datetime  TIMESTAMP,
    event_type      VARCHAR(20),
    event_desc      TEXT
);

-- Insert data
INSERT INTO my_events (
    event_name,
    event_date,
    event_datetime,
    event_type,
    event_desc
) VALUES
('New Year''s Day', '2025-01-01', '2025-01-01 00:00:00', 'Holiday',
 'A global celebration marking the beginning of the New Year, often involving fireworks, parties, and cultural traditions.'),
('Lunar New Year', '2025-01-29', '2025-01-29 10:00:00', 'Holiday',
 'A major cultural celebration in many Asian countries, featuring family reunions, feasts, and rituals for good fortune.'),
('Persian New Year', '2025-03-20', '2025-03-20 12:00:00', 'Holiday',
 'Also known as Nowruz, this event marks the start of spring and symbolizes renewal and rebirth.'),
('Birthday', '2025-05-13', '2025-05-13 18:00:00', 'Personal',
 'A personal celebration marking the anniversary of birth, often involving family, friends, and reflection.'),
('Last Day of School', '2025-06-12', '2025-06-12 15:30:00', 'Personal',
 'Marks the end of the academic year, often celebrated with excitement for the summer break.'),
('Vacation', '2025-08-01', '2025-08-01 08:00:00', 'Personal',
 'A break from routine for relaxation, travel, and creating memorable experiences.'),
('First Day of School', '2025-08-18', '2025-08-18 08:30:00', 'Personal',
 'The beginning of a new academic year, involving new goals, teachers, and experiences.'),
('Halloween', '2025-10-31', '2025-10-31 18:00:00', 'Holiday',
 'A festive event with costumes, trick-or-treating, and themed celebrations.'),
('Thanksgiving', '2025-11-27', '2025-11-27 12:00:00', 'Holiday',
 'A holiday centered on gratitude, typically celebrated with a large family meal.'),
('Christmas', '2025-12-25', '2025-12-25 09:00:00', 'Holiday',
 'A global holiday commemorating the birth of Jesus Christ, marked by gifts and family gatherings.');

-- View table
SELECT * FROM my_events;

-- Spell out the full days of the week using CASE statements
WITH dow AS (
    SELECT
        event_name,
        event_date,
        event_datetime,
        EXTRACT(YEAR FROM event_date) AS event_year,
        EXTRACT(MONTH FROM event_date) AS event_month,
        EXTRACT(DOW FROM event_date) AS event_dow
    FROM my_events
)
SELECT
    *,
    CASE
        WHEN event_dow = 0 THEN 'Sunday'
        WHEN event_dow = 1 THEN 'Monday'
        WHEN event_dow = 2 THEN 'Tuesday'
        WHEN event_dow = 3 THEN 'Wednesday'
        WHEN event_dow = 4 THEN 'Thursday'
        WHEN event_dow = 5 THEN 'Friday'
        WHEN event_dow = 6 THEN 'Saturday'
        ELSE 'Unknown'
    END AS event_dow_name
FROM dow;


-- Calculate the number of days until each event
SELECT
    event_name,
    event_date,
    event_datetime,
    CURRENT_DATE,
    (CURRENT_DATE - event_date) AS days_until
FROM my_events;

-- Add 1 minute to datetime
SELECT
    event_name,
    event_date,
    event_datetime,
    event_datetime + INTERVAL '1 minute' AS plus_one_minute
FROM my_events;


-- Add ship dates 2 days after the 2024 order_date
SELECT
    customer_id,
    order_id,
    order_date,
    order_date + INTERVAL '2 days' AS ship_date
FROM orders
WHERE EXTRACT(QUARTER FROM order_date) = 2
  AND EXTRACT(YEAR FROM order_date) = 2024;



----------------------------- 4. STRING FUNCTIONS ------------------------------
-- They can be applied to string columns (char, varchar, text, etc)

-- Change the case
SELECT event_name, UPPER(event_name), LOWER(event_name)
FROM my_events;


-- Clean up event type and find the length of the description
SELECT 		event_name, event_type, event_desc,
			TRIM(REPLACE(event_type, '!', '')) AS event_type_clean, -- Trim white spaces and replace ! with nothing
			-- REPLACE(TRIM(event_type), '!', '') AS event_type_clean,  -- also works
			LENGTH(event_desc) AS len_event_desc
FROM 		my_events;



-- Combine the type and description columns
WITH event_clean AS (SELECT event_name, event_type, event_desc,
							TRIM(REPLACE(event_type, '!', '')) AS event_type_clean,
							LENGTH(event_desc) AS len_event_desc
					 FROM my_events)
SELECT event_name, event_type_clean, event_desc,
		CONCAT(event_type_clean, ' | ', event_desc) AS full_desc
FROM event_clean		 
;


-- Clean factory name and create factory-product ID
WITH fp AS (
    SELECT
        factory,
        product_id,
        REPLACE(REPLACE(factory, '''', ' '), ' ', '-') AS factory_clean
    FROM products
)
SELECT
    factory_clean,
    product_id,
    CONCAT(factory_clean, '-', product_id) AS factory_product_id
FROM fp
ORDER BY factory_clean, product_id;


-- Using REGEX
WITH cleaned AS (
    SELECT
        factory,
        product_id,
        REGEXP_REPLACE(factory, '[^a-zA-Z0-9]+', '-', 'g') AS factory_clean
    FROM products
)
SELECT
    factory,
    product_id,
    factory_clean,
    CONCAT(factory_clean, '-', product_id) AS factory_product_id
FROM cleaned;


----------------------------- PATTERN MATCHING ------------------------------
-- Return the first word of each event
SELECT
    event_name,
    CASE
        WHEN POSITION(' ' IN event_name) = 0 THEN event_name
        ELSE SUBSTRING(event_name FROM 1 FOR POSITION(' ' IN event_name) - 1) -- from first letter to letter before ' '
    END AS first_word
FROM my_events;


-- Using REGEX
SELECT
    event_name,
    SPLIT_PART(event_name, ' ', 1) AS first_word
FROM my_events;


-- Return descriptions that contain 'family'
SELECT	*
FROM	my_events
WHERE	event_desc LIKE '%family%';

-- Return descriptions that start with 'A'
SELECT	*
FROM	my_events
WHERE	event_desc LIKE 'A %';

-- Return students with three letter first names
SELECT	*
FROM	students
WHERE	student_name LIKE '___ %'; -- 3 letters and space

-- Note any celebration word in the sentence
SELECT	event_desc,
		REGEXP_SUBSTR(event_desc, 'celebration|festival|holiday') AS celebration_word
FROM	my_events
WHERE	event_desc LIKE '%celebration%'
		OR event_desc LIKE '%festival%'
        OR event_desc LIKE '%holiday%';
		

-- Return all hyphenated words/phrases
SELECT
    event_desc,
    match[1] AS hyphen_phrase
FROM my_events,
LATERAL regexp_matches(event_desc, '([A-Za-z]+(-[A-Za-z]+)+)', 'g') AS match;


-- Remove 'Wonka Bar' from any products that contain them
SELECT	product_name,
		REPLACE(product_name, 'Wonka Bar - ', '') AS new_product_name
FROM	products;



------------------------------ 5. NULL FUNCTIONS ------------------------------------
-- They are used to replace NULL values with an alternative value.

-- Create a contacts table
CREATE TABLE contacts (
    name VARCHAR(50),
    email VARCHAR(100),
    alt_email VARCHAR(100));

INSERT INTO contacts (name, email, alt_email) VALUES
	('Anna', 'anna@example.com', NULL),
	('Bob', NULL, 'bob.alt@example.com'),
	('Charlie', NULL, NULL),
	('David', 'david@example.com', 'david.alt@example.com');

SELECT * FROM contacts;

-- Return null values
SELECT 	*
FROM 	contacts
WHERE	email IS NULL;

-- Return non-null values
SELECT 	*
FROM 	contacts
WHERE	email IS NOT NULL;

-- Return non-NULL values using a CASE statement
SELECT 	name, email,
		CASE WHEN email IS NOT NULL THEN email
			 ELSE 'no email' END AS contact_email
FROM 	contacts;

-- Return an alternative field after multiple checks
SELECT 	name, email, alt_email,
        COALESCE(email, alt_email, 'no email') AS contact_email_coalesce
FROM 	contacts;


-- Fill the NULL values in division column with the factory's top division
WITH np AS (SELECT factory, division, COUNT(product_name) AS num_products
			FROM products
			WHERE division IS NOT NULL
			GROUP BY factory, division),
	np_rank AS (SELECT factory, division, num_products,
				ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS np_rank
			FROM np),
	top_div AS (SELECT factory, division
			FROM np_rank
			WHERE np_rank =1)
SELECT  p.product_name, p.factory, p.division,
		COALESCE(p.division, 'Other') AS division_other,
		COALESCE(p.division, td.division) AS division_top
FROM    products p LEFT JOIN top_div td
		ON p.factory = td.factory
ORDER BY p.factory, p.division;









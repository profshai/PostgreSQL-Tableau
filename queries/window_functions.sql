/* ------------------- WINDOW FUNCTIONS BASICS ------------------- 
They are used to apply a function to a "window" of data
Windows are essentially groups of rows of data.

ROW_NUMBER() function returns a series of numbers for each window

Difference with aggregate functions such as GROUP BY is that aggregate functions collapse
rows in each group and apply a calculation, but window functions leave the rows as they are
and apply calculations by window


------------- COMPONENTS
ROW_NUMBER() OVER (PARTITION BY country ORDER BY happiness_score)

1. ROW_NUMBER - Function to apply to each window. Others include ROW_NUMBER, FIRST_VALUE, LAG (required)
2. OVER - States that this is a window function (required)
3. PARTITION BY - Shows how the rows are split into windows: one or multiple columns or entire table (optional)
4. ORDER BY - How each window should be sorted before a function is applied (optional for most RDBMS)
*/

-- Return all row numbers within each window
SELECT country, year, happiness_score,
		ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score DESC) AS row_num
FROM happiness_scores
ORDER BY country, row_num;


/* Given that we have an orders report with customer, order and transaction IDs, 
can you provide the transaction number for each customer as well? */
SELECT customer_id, order_id, transaction_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_id) AS transaction_num
FROM orders
ORDER BY customer_id, transaction_id;


/* --------------- ROW NUMBERING ---------------- 

ROW_NUMBER() gives every row a unique number
RANK() account for ties
DENSE_RANK() accounts for ties and leave no missing numbers in between
*/

/* --------------- ROW_NUMBER vs RANK vs DENSE_RANK ----------------- */
-- Create a new table for the demo

CREATE TABLE baby_girl_names (
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_girl_names (name, babies) VALUES
	('Olivia', 99),
	('Emma', 80),
	('Charlotte', 80),
	('Amelia', 75),
	('Sophia', 72),
	('Isabella', 70),
	('Ava', 70),
	('Mia', 64);
    
-- View the table
SELECT * FROM baby_girl_names;

-- Compare ROW_NUMBER vs RANK vs DENSE_RANK
SELECT 	name, babies, 
		ROW_NUMBER() OVER(ORDER BY BABIES DESC) AS babies_rn,
		RANK() OVER(ORDER BY BABIES DESC) AS babies_rank,
		DENSE_RANK() OVER(ORDER BY BABIES DESC) AS babies_drank
FROM 	baby_girl_names;


-- Which products were most popular within each order for the order_id 44262?
SELECT  order_id, product_id, units, 
		DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM orders
WHERE order_id LIKE '%44262'
ORDER BY order_id, product_rank;



/* --------------- FIRST_VALUE, LAST VALUE & NTH_VALUE ----------------- 
FIRST_VALUE() - extracts the first value in a window, in sequential row order
LAST_VALUE() - extracts the last value
NTH_VALUE() - extracts the value at a specified position
*/
-- Create a new table
CREATE TABLE baby_names (
    gender VARCHAR(10),
    name VARCHAR(50),
    babies INT);

INSERT INTO baby_names (gender, name, babies) VALUES
	('Female', 'Charlotte', 80),
	('Female', 'Emma', 82),
	('Female', 'Olivia', 99),
	('Male', 'James', 85),
	('Male', 'Liam', 110),
	('Male', 'Noah', 95);
    
-- View the table
SELECT * FROM baby_names;


-- Return the first name in each window
-- Using a subquery
SELECT * FROM
	(SELECT  gender, name, babies,
			FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies DESC) AS top_name
	FROM baby_names)
WHERE name = top_name;

-- Using a CTE
WITH tn AS (SELECT  gender, name, babies,
			FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies DESC) AS top_name
		FROM baby_names)
SELECT * FROM tn
WHERE name = top_name;


-- Return the second name in each window
SELECT * FROM
	(SELECT  gender, name, babies,
			NTH_VALUE(name, 2) OVER(PARTITION BY gender ORDER BY babies DESC) AS second_name
	FROM baby_names)
WHERE name = second_name;

-- Using ROW NUMBER to return first and second popular names
SELECT * FROM
	(SELECT  gender, name, babies,
			ROW_NUMBER() OVER(PARTITION BY gender ORDER BY babies DESC) AS popularity 
	FROM baby_names)
WHERE popularity <= 2;


-- What is the second most popular product within each order?
SELECT * FROM
(SELECT product_id, units, order_id,
		NTH_VALUE(product_id, 2) OVER(PARTITION BY order_id ORDER BY units DESC) AS second_product
		FROM orders
		ORDER BY order_id, second_product) AS sp
WHERE product_id = second_product
;


/* --------------- LEAD & LAG ----------------- 
LEAD() and LAG() allow you to return the value from the next and previous row respectively, within each window
*/

-- Return the difference between yearly happiness scores over time, by country

WITH prior_score AS (SELECT 
						country, year, happiness_score,
						LAG(happiness_score) OVER(PARTITION BY country ORDER BY year) AS lag_happiness_score
					 FROM happiness_scores)
SELECT country, year, happiness_score,
	   happiness_score - lag_happiness_score AS diff_in_scores
FROM prior_score
;

-- Produce a table showing how orders have changed over time
WITH my_cte AS 
					(SELECT     customer_id, order_id, SUM(units) AS total_units, 
					 			MIN(transaction_id) AS min_tid
				     FROM       orders
					 GROUP BY   customer_id, order_id
					 ORDER BY   customer_id, MIN(transaction_id)),
	 prior_units AS
	 				 (SELECT 	customer_id, order_id, total_units,
					 LAG(total_units) OVER(PARTITION BY customer_id ORDER BY min_tid) AS lag_orders
					 FROM my_cte )
SELECT 		customer_id, order_id, 
			total_units, lag_orders, 
			total_units - lag_orders AS difference
FROM prior_units;


/* ----------------------------- NTILE -----------------------------------------
It divides the rows in a window into a specified number of percentiles.

*/
-- Add a percentile to each row of data
SELECT	region, country, happiness_score,
		NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC) AS hs_percentile
FROM	happiness_scores
WHERE	year = 2023
ORDER BY region, happiness_score DESC;


-- For each region, return the top 25% of countries, in terms of happiness score
WITH hs_pct AS (SELECT	region, country, happiness_score,
						NTILE(4) OVER(PARTITION BY region ORDER BY happiness_score DESC)
                        AS hs_percentile
				FROM	happiness_scores
				WHERE	year = 2023)              
SELECT	*
FROM	hs_pct
WHERE	hs_percentile = 1;


-- Return the top 1% of customers in terms of spending
WITH ts AS (SELECT o.customer_id, SUM(o.units * p.unit_price) AS total_spend
			FROM orders o LEFT JOIN products p
				 ON o.product_id = p.product_id
			GROUP BY o.customer_id
			ORDER BY total_spend),
	 sp AS (SELECT customer_id, total_spend,
	 			   NTILE(100) OVER(ORDER BY total_spend DESC) AS spend_pct
			FROM ts)
SELECT *
FROM sp
WHERE spend_pct = 1;



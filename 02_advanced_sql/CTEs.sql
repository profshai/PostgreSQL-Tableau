/* ----------- [7] Common Table Expression (CTE) ------------------------ 
-- Creates a named, temporary output that can be referenced within another query


--------- Why use CTE instead of subqueries:
1. Readability: complex queries are much easier to read
2. Reusability: CTEs can be referenced multiple times within a query
3. Recursiveness: CTEs can handle recursive queries
*/

---------------------------------- READABILITY
-- Regions whose average happiness score is above the global average

WITH overall_avg AS (
    SELECT AVG(happiness_score) AS avg_score
    FROM happiness_scores
)
SELECT
    region,
    AVG(happiness_score) AS reg_avg_score
FROM happiness_scores, overall_avg
GROUP BY region, avg_score
HAVING AVG(happiness_score) > avg_score;


-- Return each country's happiness score for the year alongside the country's average happiness score

WITH country_hs AS (SELECT country, 
							AVG(happiness_score) AS avg_hs_by_country
					FROM happiness_scores
					GROUP BY country)
SELECT hs.year, hs.country, hs.happiness_score,
	   country_hs.avg_hs_by_country
FROM happiness_scores hs LEFT JOIN country_hs 
	 ON country_hs.country = hs.country;


---------------------------------- REUSABILITY
-- For each country, return countries from the same region with a lower happiness score in 2023

WITH hs AS (SELECT * FROM happiness_scores
			WHERE year = 2023)
SELECT hs1.region, hs1.country, hs1.happiness_score,
	   hs2.country, hs2.happiness_score
FROM hs hs1 INNER JOIN hs hs2
	   ON hs1.region = hs2.region
WHERE hs1.happiness_score < hs2.happiness_score;


/* The sales director wants a list of our biggest orders. In addition to sending over a list of all
the orders over $200, could you also tell him the number of orders over $200? */

WITH tas AS (
    SELECT
        o.order_id,
        SUM(o.units * p.unit_price) AS amount_spent
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY o.order_id
    HAVING SUM(o.units * p.unit_price) > 200
)
SELECT COUNT(*) AS number_of_large_orders
FROM tas;



---------------------------------- MULTIPLE CTEs
-- Finding records where happiness scores increased
SELECT *
FROM
	(WITH hs23 AS (SELECT country, happiness_score FROM happiness_scores WHERE year= 2023),
		  hs24 AS (SELECT country, ladder_score FROM happiness_scores_current)
	SELECT hs23.country, 
		   hs23.happiness_score AS hs2023, 
		   hs24.ladder_score AS hs2024
		FROM hs23 LEFT JOIN hs24
			ON hs23.country = hs24.country) AS hs_23_24
WHERE hs2023 < hs2024;


-- Alternatively
WITH 
	hs23 AS (SELECT country, happiness_score FROM happiness_scores WHERE year= 2023),
	hs24 AS (SELECT country, ladder_score FROM happiness_scores_current),
	hs_23_24 AS (SELECT hs23.country, 
		   				hs23.happiness_score AS hs2023, 
		   				hs24.ladder_score AS hs2024
				 FROM hs23 LEFT JOIN hs24
						ON hs23.country = hs24.country)
SELECT * 
FROM hs_23_24
WHERE hs2024 > hs2023;



/* Using CTEs, can you provide a list of our factories, along with the names of the products
they produce and the number of products they produce? */

WITH 
	fp AS (SELECT product_name, factory FROM products),
	fn AS (SELECT factory, COUNT(product_id) AS num_products FROM products
			GROUP BY factory)
SELECT fp.product_name, fp.factory, fn.num_products
FROM fp LEFT JOIN fn 
		ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name
;
	


/* ---------------------------------- RECURSIVE CTEs
This is a query that references itself, which is useful for generating sequences 
and working with hierarchical data.
*/

-- Return daily stock prices, including dates with missing prices
-- Example 1: Generating sequences
SELECT * FROM stock_prices;

-- Generate a column of dates
WITH RECURSIVE my_dates(dt) AS
	(SELECT '2024-11-01'
     UNION ALL
     SELECT dt + INTERVAL 1 DAY
     FROM my_dates
     WHERE dt < '2024-11-06')
     
SELECT * FROM my_dates;

-- Include the original prices
WITH RECURSIVE my_dates(dt) AS
	(SELECT '2024-11-01'
     UNION ALL
     SELECT dt + INTERVAL 1 DAY
     FROM my_dates
     WHERE dt < '2024-11-06')
     
SELECT	md.dt, sp.price
FROM	my_dates md
		LEFT JOIN stock_prices sp
        ON md.dt = sp.date;


-- Return the reporting chain for each employee
-- Example 2: Working with hierachical data
SELECT * FROM employees;

-- Return the reporting chain for each employee
WITH RECURSIVE employee_hierarchy AS (
    SELECT	employee_id, employee_name, manager_id,
			employee_name AS hierarchy
    FROM	employees
    WHERE	manager_id IS NULL
    
    UNION ALL
    
    SELECT	e.employee_id, e.employee_name, e.manager_id,
			CONCAT(eh.hierarchy, ' > ', e.employee_name) AS hierarchy
    FROM	employees e INNER JOIN employee_hierarchy eh
			ON e.manager_id = eh.employee_id
)

SELECT	employee_id, employee_name,
		manager_id, hierarchy
FROM	employee_hierarchy
ORDER BY employee_id;


/* --------------- Subquery vs CTE vs Temp Table vs View -------------------------- 
-- Both subqueries and CTEs only exist for the duration of the query. Require READ permissions only
-- TEMPORARY tables only exist for a session.. They store data for a session. Requires CREATE permissions
-- VIEWS continue to exist until modified or dropped. 
A view is not a simple table (which stores table in memory indefinitely), 
but view doesn't store a data at all, it saves a query and when you call the view, 
it runs the query on a table. They are virtual tables based on a query. Requires CREATE permissions
*/

-- Subquery
SELECT * FROM

(SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current) AS my_subquery;

-- CTE
WITH my_cte AS (SELECT	year, country, happiness_score FROM happiness_scores
				UNION ALL
				SELECT	2024, country, ladder_score FROM happiness_scores_current)       
SELECT * FROM my_cte;


--------------------------------------- Temporary table
CREATE TEMPORARY TABLE my_temp_table AS
SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current;

SELECT * FROM my_temp_table;


---------------------------------------- View
CREATE VIEW my_view AS
SELECT	year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT	2024, country, ladder_score FROM happiness_scores_current;

SELECT * FROM my_view;





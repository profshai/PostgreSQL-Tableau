
/* ----------- INNER Joining two tables 
An inner join keeps rows where the join condition is satisfied in both tables and discards everything else.
--------- */
SELECT hs.country, hs.year, hs.happiness_score, cs.continent FROM happiness_scores hs
INNER JOIN country_stats cs
ON hs.country = cs.country;


/* ----------- LEFT Joining two tables --------- */
SELECT hs.country, hs.year, hs.happiness_score, cs.continent FROM happiness_scores hs
LEFT JOIN country_stats cs
ON hs.country = cs.country
WHERE cs.country IS NULL;


/* -----------  RIGHT Joining two tables --------- */
SELECT hs.country, hs.year, hs.happiness_score, cs.continent FROM happiness_scores hs
RIGHT JOIN country_stats cs
ON hs.country = cs.country
WHERE hs.country IS NULL;;


/* ----------- FULL OUTER Joining two tables --------- */
SELECT hs.country, hs.year, hs.happiness_score, cs.continent FROM happiness_scores hs
FULL OUTER JOIN country_stats cs
ON hs.country = cs.country;


-- Countries that exist in the left table but not the right table
SELECT DISTINCT (hs.country) FROM happiness_scores hs
LEFT JOIN country_stats cs
ON hs.country = cs.country
WHERE cs.country IS NULL;


-- Which products exists in one table but not the other?
SELECT * FROM products;
SELECT * FROM orders;

SELECT * FROM products p
LEFT JOIN orders o
ON p.product_id = o.product_id
WHERE o.product_id IS NULL; -- 3 products

SELECT * FROM products p
RIGHT JOIN orders o
ON p.product_id = o.product_id
WHERE p.product_id IS NULL; -- null


/* ------------------- JOINING ON MULTIPLE COLUMNS -------------------------- */

SELECT hs.country, hs.year, hs.happiness_score, hs.gdp_per_capita, ir.inflation_rate FROM happiness_scores hs
INNER JOIN inflation_rates ir 
ON hs.year = ir.year AND hs.country = ir.country_name;



/* ------------------- JOINING 3 TABLES -------------------------- */

SELECT * FROM happiness_scores;
SELECT * FROM country_stats;
SELECT * FROM inflation_rates;

SELECT hs.year, hs.country, hs.happiness_score,
	cs.continent, ir.inflation_rate 
FROM happiness_scores hs
	LEFT JOIN country_stats cs
		ON hs.country = cs.country
	LEFT JOIN inflation_rates ir
		ON hs.country = ir.country_name AND hs.year = ir.year;


/* ------------------- SELF JOINS -------------------------- */

-- Create a table for demonstration
CREATE TABLE IF NOT EXISTS employees (
	employee_id SERIAL PRIMARY KEY,
	employee_name VARCHAR(100),
	salary INT,
	manager_id INT
);

INSERT INTO employees (
	employee_id,
	employee_name,
	salary,
	manager_id
)
VALUES 
	(1, 'Ava', 85000, NULL),
	(2, 'Bob', 72000, 1),
	(3, 'Cat', 59000, 1),
	(4, 'Dan', 85000, 2)
;


-- Employees with same salary
SELECT e1.employee_id, e1.employee_name, e1.salary,
	   e2.employee_id, e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2
	ON e1.salary = e2.salary
WHERE e1.employee_id > e2.employee_id;


-- Employees that have greater salary
SELECT e1.employee_name, e1.salary, 
	   e2.employee_name, e2.salary
FROM employees e1
INNER JOIN employees e2
	ON e1.salary > e2.salary
ORDER BY e1.employee_id;


-- Enployees and their manager
SELECT e1.employee_name, e1.salary,
	   e2.employee_name AS manager_name, e2.salary
FROM employees e1 LEFT JOIN employees e2
		 ON e1.manager_id = e2.employee_id;


-- identify which products are within 25 cents of each other in terms of unit price
SELECT p1.product_name, p1.unit_price,
	   p2.product_name, p2.unit_price, 
	   p1.unit_price - p2.unit_price AS price_diff
FROM products p1
INNER JOIN products p2
		   ON p1.product_id <> p2.product_id
		   WHERE ABS(p1.unit_price - p2.unit_price) < 0.25
		   AND p1.product_name < p2.product_name
ORDER BY price_diff DESC
;


/* ------------------- CROSS JOINS -------------------------- 
Returns all combinations of rows within two or more tables
*/
-- Create the table
CREATE TABLE tops (
    id INT,
    item VARCHAR(50)
);

CREATE TABLE sizes (
    id INT,
    size VARCHAR(50)
);

CREATE TABLE outerwear (
    id INT,
    item VARCHAR(50)
);

INSERT INTO tops (id, item) VALUES
	(1, 'T-Shirt'),
	(2, 'Hoodie');

INSERT INTO sizes (id, size) VALUES
	(101, 'Small'),
	(102, 'Medium'),
	(103, 'Large');

INSERT INTO outerwear (id, item) VALUES
	(2, 'Hoodie'),
	(3, 'Jacket'),
	(4, 'Coat');


-- identify which products are within 25 cents of each other in terms of unit price
SELECT p1.product_name, p1.unit_price,
	   p2.product_name, p2.unit_price, 
	   p1.unit_price - p2.unit_price AS price_diff
FROM products p1
CROSS JOIN products p2
		   WHERE ABS(p1.unit_price - p2.unit_price) < 0.25
		   AND p1.product_name < p2.product_name
ORDER BY price_diff DESC
;





/* ------------------- UNION vs UNION ALL -------------------------- 
-- Allows us to stack multiple tables or queries on top of one another
-- UNION removes duplicate values, while UNION ALL retains them
-- UNION ALL runs much faster because it doesn't check for duplicates (just stacks them)
*/

SELECT * FROM tops
UNION
SELECT* FROM outerwear;


SELECT * FROM tops
UNION ALL
SELECT* FROM outerwear;

-- Union with different column names
SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024, country, ladder_score FROM happiness_scores_current
ORDER BY year DESC;




/* ------------------ CASE STATEMENT ---------------------- 
-- This works like the conditional expressions (if, else, elif) in other languages.
-- There are two main ways of using a CASE statement: a general CASE or a CASE expression
-- In many situations, they can lead to the same result
-- The general CASE allows for checking many expressions (very flexible)
while the CASE expression checks one expression. 
*/

-- Categorizing customers based on ids (CASE)
SELECT customer_id, 
CASE 
	WHEN (customer_id <= 100) THEN 'Premium'
	WHEN (customer_id BETWEEN 100 AND 200) THEN 'Plus'
	ELSE 'Normal'
END AS customer_class
FROM customer;


-- Holding a raffle to pick certain customers (CASE expression)
SELECT customer_id, 
CASE customer_id
	WHEN 2 THEN 'Winner'
	WHEN 5 THEN 'Second Place'
	ELSE 'Normal'
END AS raffle_results
FROM customer;


-- counting 0.99 movies (bargains)
SELECT
SUM(CASE rental_rate
	WHEN 0.99 THEN 1
	ELSE 0
END) AS bargains,
SUM(CASE rental_rate
	WHEN 2.99 THEN 1
	ELSE 0
END) AS regular,
SUM(CASE rental_rate
	WHEN 4.99 THEN 1
	ELSE 0
END) AS premium
FROM film;


/* ----------------- CHALLENGE -----------------------
Find the number of each movie ratings in the database
*/
SELECT
SUM(CASE rating
	WHEN 'R' THEN 1
	ELSE 0
END) AS r,
SUM(CASE rating
	WHEN 'PG' THEN 1
	ELSE 0
END) AS pg,
SUM(CASE rating
	WHEN 'PG-13' THEN 1
	ELSE 0
END) AS pg13
FROM film;


/* ------------------ COALESCE Function ---------------------- 
-- It accepts unlimited number of arguments.
-- It returns the first argument that is not null. 
-- If all arguments are null, the COALESCE function returns null
-- We use it to substitute null values with other values

Syntax- set the null values in the discount column to 0:
SELECT item, (price - COALESCE(discount, 0)) AS final
FROM table
*/


/* ------------------- CAST Function ------------------------- 
-- We use it to convert from one data type into another. eg. '5' into 5
-- We obviousy cannot convert 'five' into 5
-- We use it in a SELECT query with a column name instead of a single instance.

-- Syntax:
SELECT CAST('5' AS INTEGER) or SELECT CAST('5'::INTEGER)
*/

SELECT CAST('5' AS INTEGER) AS int;

-- Count the number of integers in the inventory_id column
SELECT CHAR_LENGTH(CAST(inventory_id AS VARCHAR)) FROM rental;


/* ------------------- NULLIF -------------------------------
-- It takes in 2 inputs and returns NULL if both are equal, otherwise returns the first argument passed
-- It becomes useful in cases where a NULL value would cause an error or unwanted result.

NULLIF(10, 10) returns NULL since 10=10
NULLIF(10, 12) returns 10 since 10 is not equal to 12
*/

-- Return NULL instead of an error when the department B is 0
SELECT (
SUM(CASE WHEN department ='A' THEN 1 ELSE 0 END)/
NULLIF(CASE WHEN department ='B' THEN 1 ELSE 0 END, 0)
) AS department_ratio
FROM depts


/* ------------------------------- Views ----------------------
-- Instead of having to perform the same query over and over, 
you can create a VIEW to quickly see this query with a simple call.
-- A view is a database object that is of a stored query.
-- It does not store the data physically (virtual table), it simply stored the query.
*/

-- Create a view called customer_info for later use
CREATE VIEW customer_info AS
SELECT first_name, last_name, address FROM customer
INNER JOIN address
ON customer.address_id = address.address_id;


-- Calling our view
SELECT * FROM customer_info;


-- Changing a created view
CREATE OR REPLACE VIEW customer_info AS
SELECT first_name, last_name, address, district FROM customer
INNER JOIN address
ON customer.address_id = address.address_id;


-- Remove view
DROP VIEW IF EXISTS customer_info;

-- Rename a view
ALTER VIEW  customer_info RENAME TO c_info;

SELECT * FROM c_info;



/* ------------------------------ IMPORT and EXPORT functions ----------------------
-- Allows us to import/export data from/to a .csv file to/from an already existing table
-- Not every outside data file will work...when there are compatibility issues
*/



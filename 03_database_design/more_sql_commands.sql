/*----------------------- ADVANCED SQL COMMANDS ------------------- */

/* --------------------------------------- Timestamps and Extract
TIME - Contains only (h,m,s)
DATE - Contains only date (y, m, d)
TIMESTAMP - Contains date and time
TIMESTAMPZ - Contains date, time and timezone

These are more useful when creating a database
*/

-- Check timezone
SHOW TIMEZONE;

-- Check Timestamp
SELECT NOW();

-- String
SELECT TIMEOFDAY();

-- Current time
SELECT CURRENT_TIME;

-- Current date
SELECT CURRENT_DATE;


/* -------------------------------- EXTRACT()
Allows you to extract or obtain a sub-component of a date value
AGE() - Calculates and returns the current age given a timestamp
TO_CHAR() - General function to convert data types to text. It is useful for timestamp formatting
*/

-- Extract year
SELECT EXTRACT(YEAR FROM payment_date) AS year
FROM payment;

-- Extract month
SELECT EXTRACT(MONTH FROM payment_date) AS pay_month
FROM payment;


-- Extract quarter
SELECT EXTRACT(QUARTER FROM payment_date) AS quarter
FROM payment;


-- Extract age
SELECT AGE(payment_date)
FROM payment;


-- To_char
SELECT TO_CHAR(payment_date, 'YYYY-MM-DD')
FROM payment;


SELECT TO_CHAR(payment_date, 'mon/dd/YYYY')
FROM payment;

SELECT TO_CHAR(payment_date, 'MM/dd/YYYY')
FROM payment;

SELECT TO_CHAR(payment_date, 'MM-dd-YYYY')
FROM payment;


/* ---------------------- CHALLENGES -------------------------
QUESTION 1: 
During which months did payments occur? Format your answer to return the full month name
*/
SELECT DISTINCT (TO_CHAR(payment_date, 'MONTH'))
FROM payment;


/* ---------------------- CHALLENGES -------------------------
QUESTION 2: 
Mow many payments occurred on a Monday? 
*/
SELECT COUNT(*)
FROM payment
WHERE EXTRACT(dow FROM payment_date) = 1;



/* ------------------- MATHEMATICAL FUNCTIONS AND OPERATORS ---------------*/
SELECT ROUND(rental_rate/replacement_cost, 2)* 100 AS percent_cost
FROM film;

-- Put down 10 percent of replacement cost
SELECT 0.1* replacement_cost AS deposit
FROM film;


/* ------------------- STRING FUNCTIONS AND OPERATORS ---------------
They allow us to edit, combine and alter text data columns.
*/
-- Length of first_names
SELECT LENGTH(first_name) FROM customer;

-- Concatenate first and last names
SELECT UPPER(first_name) || ' ' || last_name AS full_name
FROM customer;

-- Create email for customers
SELECT LOWER(LEFT(first_name, 1)) || LOWER(last_name) || '@gmail.com' 
AS email
FROM customer;


/* ------------------- SUBQUERY ---------------
-- Allows us to construct more complex query, essentially performing a query on the results of another query.
-- The syntax involves two SELECT statements.
-- The subquery is performed first since it is inside the parenthesis
-- We can also use the IN operator in conjunction with a subquery to 
check against multiple results returned
-- The EXISTS operator is used to test for existence of rows in a subquery
*/

-- We want rental rate > the average
SELECT title, rental_rate FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);

SELECT *  FROM film;
SELECT *  FROM rental;
SELECT * FROM inventory;

-- Find movies that have been returned
SELECT title, film_id FROM film
WHERE film_id IN
(SELECT inventory.film_id
FROM rental
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
WHERE return_date BETWEEN '2005-05-29' AND '2005-05-30')
ORDER BY title;

-- Customer with at least one payment > 11
SELECT first_name, last_name
FROM customer AS c
WHERE EXISTS
(SELECT * FROM payment as p
WHERE p.customer_id = c.customer_id
AND amount > 11)



/* ------------------- SELF-JOIN ---------------
This is a query in which a table is joined to itself.
Self-joins are useful for comparing values in a column of rows within the same table.
It can be viewed as a join of two copies of the same table: SQL performs the command as though there are two copies
It is necessary to use an alias for the table, otherwise the table names would be ambiguous.

eg syntax:*/
SELECT emp.name, report.name AS rep
FROM employees AS emp
JOIN employees AS report 
ON emp.emp_id = report.report.id

-- Find all the pairs of film that have the same length
SELECT f1.title, f2.title, f1.length 
FROM film AS f1
JOIN film AS f2
ON f1.film_id != f2.film_id
AND f1.length = f2.length;




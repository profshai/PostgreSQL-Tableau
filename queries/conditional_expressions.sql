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


*/







SELECT * FROM customer;
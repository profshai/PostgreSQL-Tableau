/* UNDERSTANDING THE GROUPBY STATEMENT AND AGGREGATE FUNCTIONS */

--- AGGREGATE FUNCTIONS
/* The most common aggregate functions are:
AVG()
COUNT()
MAX()
MIN()
SUM()
*/

-- What are the minimum and maximum replacement costs?
SELECT MIN(replacement_cost), MAX(replacement_cost) FROM film;

-- What is the average replacement cost?
SELECT ROUND(AVG(replacement_cost), 2) FROM film;

-- How much will it cost us to replace all the films?
SELECT SUM(replacement_cost) FROM film;


--- GROUP BY: allows us to aggregate columns per some category
/* In the SELECT statement of a GROUP BY, 
columns must either have an aggregate function or be in the GROUP BY call 
The WHERE STATEMENT should not refer to the aggregation result... Use HAVING 
ORDER BY should reference the entire function: eg SUM(sales), not sales */

-- What customer is spending the most money in total?
SELECT customer_id, SUM(amount) FROM payment
GROUP BY customer_id
ORDER BY SUM(amount)
LIMIT 5;

-- What customer has the most transactions?
SELECT customer_id, COUNT(amount) FROM payment
GROUP BY customer_id
ORDER BY COUNT(amount) DESC
LIMIT 10;

-- Grouping by customer_id, staff_id to see how much each customer spent with each staff
SELECT customer_id, staff_id, SUM(amount) FROM payment
GROUP BY customer_id, staff_id
ORDER BY customer_id;

-- What are the days with most dollar transactions?
-- DATE() extract the actual year, month and date
SELECT DATE(payment_date), SUM(amount) FROM payment
GROUP BY DATE(payment_date)
ORDER BY SUM(amount) DESC;


------------------------------------------ CHALLENGES ------------------------------------------
/* QUESTION 1: 
We have two staff members, with staff IDs 1 and 2. We want to give a bonus to the staff member that
handled the most payments (most in terms of the number of payments processed, not total dollar amount).
How many payments did each staff member handle and who gets the bonus? 
*/
SELECT staff_id, COUNT(payment_id) FROM payment
GROUP BY staff_id
ORDER BY staff_id, COUNT(payment_id);


/* QUESTION 2: 
Corporate HQ is conducting a study on the relationship between replacement cost and a movie MPAA rating (e.g. G, PG, R, etc)
What is the avegage replacement cost per MPAA rating?
*/
SELECT rating, ROUND(AVG(replacement_cost), 2) FROM film
GROUP BY rating;


/* QUESTION 3: 
We are running a promotion to reward our top 5 customers with coupons. 
What are the customer ids of the top 5 customers by total spend?
*/
SELECT customer_id, SUM(amount) FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 5;


--- HAVING - allows us after an aggregation has taken place
/* 
It comes after the GROUP BY call
It allows us to use the aggregate result as a filter along with a GROUP BY 
*/
-- customer ids of customer with total amount of more than 100, and excluding certain customers
SELECT customer_id, SUM(amount) FROM payment
WHERE customer_id NOT IN (184, 87, 477)
GROUP BY customer_id
HAVING SUM(amount) > 100
ORDER BY customer_id;


-- The number of customers per store
SELECT store_id,  COUNT(customer_id) FROM customer
GROUP BY store_id;

------------------------------------------ CHALLENGES ------------------------------------------
/* QUESTION 1: 
We are launching a platinum service for our most loyal customers. We will assign platinum status
to customers that have had 40 or more transaction payments. 
What customer ids are eligible for platinum status?
*/
SELECT customer_id, COUNT(amount) FROM payment
GROUP BY customer_id
HAVING COUNT(amount) >= 40;


/* QUESTION 2: 
What are the customer ids of customers who have spent more than $100 
in payment transactions with our staff_id member 2
*/
SELECT customer_id, SUM(amount) FROM payment
WHERE staff_id = 2
GROUP BY customer_id
HAVING SUM(amount) > 100;




------------------------------------------ ASSESSMENT TEST 1 ------------------------------------------
/* QUESTION 1: 
Return the customer IDs of customers who have spent at least $110 
with the staff member who has an ID of 2
*/
SELECT customer_id, SUM(amount) FROM payment
WHERE staff_id = 2
GROUP BY customer_id
HAVING SUM(amount) >= 110;

/* QUESTION 2: 
How many films begin with the letter J
*/
SELECT COUNT(*) FROM film
WHERE title LIKE 'J%';


/* QUESTION 3: 
What customer has the highest customer ID number who name starts with an 'E'
and has an address ID lower than 500
*/
SELECT customer_id, first_name, last_name FROM customer
WHERE first_name LIKE 'E%' AND address_id < 500
ORDER BY address_id DESC
LIMIT 1;



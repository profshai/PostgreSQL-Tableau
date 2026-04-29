/* SQL QUERIES OF A DVD RENTAL DATABASE */

--- SELECT STATEMENT
/* We want to send out a promotional email to our existing customers. 
We need their first and last names and their email addresses */
SELECT first_name, last_name, email FROM customer;


--- SELECT DISTINCT
/* We have an Australian visitor who isn't familiar with MPAA movie ratings. 
We need to show him the different movie ratings we have in our database. */
SELECT DISTINCT rating FROM film;

--- SELECT COUNT()
-- Number of rows in the payment table
SELECT COUNT (*) FROM payment;

-- Count the number of unique ratings
SELECT COUNT(DISTINCT rating) FROM film;

-- Count the number of unique payment amount
SELECT COUNT(DISTINCT amount) FROM payment;

--- SELECT WHERE
/* A customer forgot their wallet at our store. We need to track down their email to inform them.
What is the email for the customer with the name Nancy Thomas */
SELECT email FROM customer
WHERE first_name = 'Nancy' AND last_name = 'Thomas';

/* A customer wants to know what the movie "Outlaw Hanky" is about. 
Could you give them the description of the movie? */
SELECT description FROM film
WHERE title = 'Outlaw Hanky';

/* A customer is lateon their movie return, and we've mailed them a letter to their address at '259 Ipoh Drive'.
We should also call them on the phone to let them know.
Can you get the phone number for the customer? */
SELECT phone FROM address
WHERE address = '259 Ipoh Drive';


--- ORDER BY
SELECT store_id, first_name, last_name FROM customer
ORDER BY store_id DESC, first_name ASC; -- DESC for Descending order... ASC for Ascending order


--- LIMIT: to limit the number of rows returned for query
--- It is the last statement to be executed
/* What are the 10 most recent payments from the payment table where amount is more than $3.0? */
SELECT * FROM payment
WHERE amount > 3
ORDER BY payment_date DESC
LIMIT 10;


/* We want to reward out first 10 paying customers.
What are the customer ids of these customers? */
SELECT customer_id, amount FROM payment
WHERE amount > 0
ORDER by payment_date
LIMIT 10;


/* A customer wants to quickly rent a video to watch over their short lunch break.
What are the titles of the 5 shortest (in length of runtime) movies? */
SELECT title, length FROM film
ORDER BY length
LIMIT 5;


/* If the previous customer can watch any movie that is 50 minutes or less in runtime,
how many options does she have? */
SELECT COUNT(title) FROM film
WHERE length <= 50;


--- BETWEEN: includes end values... Can be used with Dates
SELECT * FROM payment
WHERE amount BETWEEN 8 AND 9;

--- NOT BETWEEN
SELECT * FROM payment
WHERE amount NOT BETWEEN 8 AND 9;

--- BETWEEN with DATES
SELECT * FROM payment
WHERE payment_date BETWEEN '2007-01-01' AND '2007-02-15'; -- Always double-check


--- IN: to check if a value is included in a list of multiple options
SELECT * FROM payment
WHERE amount IN (0.99, 1.98, 1.99);


SELECT * FROM payment
WHERE amount NOT IN (0.99, 1.98, 1.99);


SELECT * FROM customer
WHERE first_name IN ('John', 'Julie', 'Shaibu');


--- LIKE and ILIKE
/* The LIKE operator allows us to perform pattern matching against a string data using wildcards such as 
- Percent % to match any sequence of characters: 
All names that begin with an 'A': WHERE name LIKE 'A%'
All names that end with an 'a': WHERE name LIKE '%a'
- Underscore _ to match any single character
We can use multiple _
WHERE title LIKE 'Mission Impossible_' or WHERE title LIKE 'Mission Impossible___'
WHERE name LIKE '_her%' may return: [Cheryl, Theresa, Sherri)

NB: LIKE is case-sensitive but ILIKE is not */

/* Select all names where the first name begins with 'J' 
and last name begins with S from the customer table */
SELECT first_name, last_name FROM customer
WHERE first_name LIKE 'J%' AND last_name LIKE 'S%';


/* Anyone with 'er' in their first names */
SELECT first_name, last_name FROM customer
WHERE first_name LIKE '%er%' AND last_name NOT LIKE 'B%'
ORDER BY last_name;



/* GENERAL CHALLENGE 1
-- QUESTION 1: How many payment transactions were greater than $5.00? */
SELECT COUNT(*) FROM payment
WHERE amount > 5; 

-- QUESTION 2: How many actors have a first name that starts with the letter P?
SELECT COUNT(*) FROM actor
WHERE first_name LIKE 'P%';

-- QUESTION 3: How many unique district are our customers from?
SELECT COUNT (DISTINCT (district)) FROM address;

-- QUESTION 4: Retrieve the list of names for those distinct districts from the previous question
SELECT DISTINCT (district) FROM address;

-- QUESTION 5: How many films have a rating of R and a replacement cost between $5 and $15?
SELECT COUNT(*) FROM film
WHERE rating = 'R' 
AND replacement_cost BETWEEN 5 AND 15;

-- QUESTION 6: What are the films with the word Truman somewhere in the title?
SELECT title FROM film
WHERE title like '%Truman%';



-- Credit from Jose Portilla (Udemy)





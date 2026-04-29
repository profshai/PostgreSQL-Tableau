/* ************************************ JOINS ************************************/
/* Joins allow to combine multiple tables together */

/*----------------------------------- AS STATEMENT
It allows us to create an alias for a column or result
Cannot be used in a WHERE or HAVING statement because
it get assigned at the end of the query
*/
--- Count the number of transactions and rename the output column
SELECT COUNT(amount) AS num_transactions 
FROM payment;


/*------------------------------------ INNER JOINS
Looks at a set of records that match in multiple tables
Table order won't matter in an inner join
*/

/* Select the payment_id, customer_id and amount from the payment table and join them to 
the first_name and last_name of the customers who spent more than $5 */
SELECT payment_id, payment.customer_id, amount, first_name, last_name FROM payment
INNER JOIN customer
ON payment.customer_id = customer.customer_id
WHERE amount > 5;


/*------------------------------------ FULL OUTER JOINS
Grabs everything whether it is present in only one table.

We want to make sure there is no payment information not attached to a customer or 
that we don't have a customer information not attached to a payment */

SELECT * FROM customer
FULL OUTER JOIN payment
ON customer.customer_id = payment.customer_id
WHERE customer.customer_id IS null 
OR payment.payment_id IS NULL;

--- We can confirm the result above using the following 
--- but the following in itself doesn't answer the above question
SELECT COUNT(DISTINCT (customer_id)) FROM payment;
SELECT COUNT(DISTINCT (customer_id)) FROM customer;



/*------------------------------------ LEFT (OUTER) JOINS
-- It results in the sets of records that are in the left table and 
if there is no match with the right table, the results are NULL.
-- We want records exclusive to table A or can be found in both A and B.
-- Table order matters here
-- We can use a WHERE clause to select only records unique to the left table

We want records of film_id in film table but not in inventory table.
Basically, it shows films we have information about but that are not in our inventory */
SELECT film.film_id, film.title, inventory_id, store_id 
FROM film
LEFT JOIN inventory ON
inventory.film_id = film.film_id
WHERE inventory.film_id IS NULL;



/*------------------------------------ RIGHT (OUTER) JOINS
-- It's the same as the left join except that the tables are switched. */


/*------------------------------------ UNIONS
-- They are used to combine the result-set of two or more SELECT statements 
-- It basically serve to directly concatenate two results together, essentionally "pasting" them together 

The syntax:
SELECT * FROM Table1
UNION
SELECT * FROM Table2

*/


------------------------------------------ CHALLENGES ------------------------------------------
/* QUESTION 1: 
California sales tax laws have changed and we need to alert our customer to this through email. 
What are the emails of customers who live in california?
*/

SELECT first_name, last_name, district, email FROM customer
INNER JOIN address 
ON customer.address_id = address.address_id
WHERE district = 'California';

/* QUESTION 2: 
A customer walks in and is a huge fan of Nick Wahlberg, and wants to know which movies he's in
Get a list of all the movies Nick Wahlberg has been in
*/

SELECT first_name, last_name, title FROM actor 
INNER JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
INNER JOIN film
ON film_actor.film_id = film.film_id
WHERE first_name = 'Nick' and last_name = 'Wahlberg';






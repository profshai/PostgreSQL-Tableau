/************************************* JOINS ************************************/

/*--- AS STATEMENT
It allows us to create an alias for a column or result
Cannot be used in a WHERE or HAVING statement because
it get assigned at the end of the query
*/
--- Count the number of transactions and rename the output column
SELECT COUNT(amount) AS num_transactions 
FROM payment;


/*--- INNER JOINS


*/









------------------------------------------ CHALLENGES ------------------------------------------
/* QUESTION 1: 
We have two staff members, with staff IDs 1 and 2. We want to give a bonus to the staff member that
handled the most payments (most in terms of the number of payments processed, not total dollar amount).
How many payments did each staff member handle and who gets the bonus? 
*/
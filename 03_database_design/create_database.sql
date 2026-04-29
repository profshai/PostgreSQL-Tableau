/* -------------------------------------------- CREATING TABLES AND DATABASES ----------------------- 
SERIAL is used for the primary key column.. makes sure the values are unique
NOT NULL means the column cannot be blank
*/

-- First Table: account
CREATE TABLE account(
	user_id SERIAL PRIMARY KEY,
	age SMALLINT NOT NULL,
	username VARCHAR(50) UNIQUE NOT NULL,
	password VARCHAR(50) NOT NULL,
	email VARCHAR(250) UNIQUE NOT NULL,
	created_on TIMESTAMP NOT NULL,
	last_login TIMESTAMP
)


-- Second Table: job
CREATE TABLE job(
	job_id SERIAL PRIMARY KEY,
	job_name VARCHAR(200) UNIQUE NOT NULL
)


-- Third Table: account_job.. Same user_id as in account table.
CREATE TABLE account_job(
	user_id INTEGER REFERENCES account(user_id),
	job_id INTEGER REFERENCES job(job_id),
	hire_date TIMESTAMP NOT NULL
)


/* --------------------------------------------- INSERT --------------------------- */
INSERT INTO account(age, username, password, email, created_on, last_login)
VALUES
(40, 'Jose', 'password', 'shai@gmail.com', CURRENT_TIMESTAMP, NOW());


INSERT INTO job(job_name)
VALUES
('astronaut');

INSERT INTO job(job_name)
VALUES
('data scientist');

/* CONNECT TABLES 
user_id and job_id must exist in other tables, else there will be an error
constraints should not be violated
*/
INSERT INTO account_job(user_id, job_id, hire_date)
VALUES
	(2, 1, CURRENT_TIMESTAMP)

SELECT * FROM account_job


/* ---------------------------------------- UPDATE --------------------------------
It is used to change the values of a table 
*/
-- updating last_login to match the current timestamp
UPDATE account
SET last_login = CURRENT_TIMESTAMP;

-- updating last_login to match the current created_on time
UPDATE account
SET last_login = created_on;


-- UPDATE JOIN: updating based on results from another table
UPDATE account_job
SET hire_date = account.created_on
FROM account
WHERE account_job.user_id = account.user_id;

SELECT * FROM account_job;
SELECT * FROM account;


-- RESETTING account table
UPDATE account
SET last_login = CURRENT_TIMESTAMP
RETURNING email, created_on, last_login; -- To make sure query ran properly



/* ----------------------------------------- DELETE clause--------------
Used to remove rows from a table
*/
INSERT INTO job(job_name)
VALUES
('economist');
SELECT * FROM job;

-- Delete it
DELETE FROM job
WHERE job_name = 'economist'
RETURNING job_id, job_name; -- returns what was deleted


/* ----------------------------------------- ALTER clause--------------
Used to make changes to an existing data structure 
such as adding, dropping or renaming columns, changing data type,
set DEFAULT values for a column, add CHECK constraints, or rename a table
*/
CREATE TABLE information(
	info_id SERIAL PRIMARY KEY,
	title VARCHAR(500) NOT NULL,
	person VARCHAR(500) NOT NULL UNIQUE
);

SELECT * FROM information;

-- RENAME table
ALTER TABLE information
RENAME TO new_info;

SELECT * FROM new_info;

-- RENAME column
ALTER TABLE new_info
RENAME COLUMN person TO people;

-- ALTER constraints
-- Drop NOT NULL constraint in the people column
ALTER TABLE new_info
ALTER COLUMN people DROP NOT NULL;

-- Insert new data into title column without adding to the people column
-- This returns no error because the constraint has been removed
INSERT INTO new_info(title)
VALUES
('some new title');


/* ----------------------------------------- DROP Table clause --------------
-- Allows us to completely remove a column of a table.
-- This will remove all of its indexes and constraints.
-- However, it will not remove columns used in views, triggers, or stored procedures
without the additional CASCADE clause.
-- Try to drop a column that doesn't exist will return an error-- recommended to include IF EXISTS in query
*/

-- Drop the people column in the new_info table
ALTER TABLE new_info
DROP COLUMN people;

SELECT * FROM new_info;

-- Attempts to drop column only if it exists
ALTER TABLE new_info
DROP COLUMN IF EXISTS people;


/* ----------------------------------------- CHECK constraint --------------
-- Allows us to create more customized constraints that adhere to a certain condition
-- Such as making sure all inserted integer values fall below a certain threshold
*/
CREATE TABLE employees (
	emp_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birthdate DATE CHECK (birthdate > '1900-01-01'),
	hire_date DATE CHECK (hire_date > birthdate),
	salary INTEGER CHECK(salary > 0)
);

SELECT * FROM employees;

INSERT INTO employees (
first_name,
last_name,
birthdate,
hire_date,
salary
)
VALUES
('Shai', 'Bu', '2020-01-01', '2019-01-01', -2);

-- The above produces errors because of the hire_date and salary constraints

INSERT INTO employees (
first_name,
last_name,
birthdate,
hire_date,
salary
)
VALUES
('Shai', 'Bu', '2020-01-01', '2026-01-01', 90000);

SELECT * FROM employees;





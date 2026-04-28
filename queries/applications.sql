/* -------------- SQL DATA ANALYSIS APPLICATIONS ------------------------*/


--------------------------------- 1. DUPLICATE VALUES -----------------------------------
-- Create Table
CREATE TABLE employee_details (
    region VARCHAR(50),
    employee_name VARCHAR(50),
    salary INTEGER
);

INSERT INTO employee_details (region, employee_name, salary) VALUES
	('East', 'Ava', 85000),
	('East', 'Ava', 85000),
	('East', 'Bob', 72000),
	('East', 'Cat', 59000),
	('West', 'Cat', 63000),
	('West', 'Dan', 85000),
	('West', 'Eve', 72000),
	('West', 'Eve', 75000);

-- View the employee details table
SELECT * FROM employee_details;

-- 1. View duplicate rows
SELECT region, employee_name, salary, COUNT(*) AS dup_count
FROM employee_details
GROUP BY region, employee_name, salary
HAVING COUNT(*) > 1;


-- 2. Exclude fully duplicate rows
SELECT DISTINCT region, employee_name, salary
FROM employee_details;


-- 3. Exclude partially duplicate rows (assume Cat is one person)
WITH cte AS (SELECT region, employee_name, salary,
				ROW_NUMBER() OVER(PARTITION BY employee_name ORDER BY salary DESC) AS top_sal
			FROM employee_details)
SELECT *
FROM cte 
WHERE top_sal = 1
ORDER BY salary DESC;


-- 4. We want unique region, employee_name combo (Get both Cat)
WITH cte AS (SELECT region, employee_name, salary,
				ROW_NUMBER() OVER(PARTITION BY region, employee_name ORDER BY salary DESC) AS top_sal
			FROM employee_details)
SELECT *
FROM cte 
WHERE top_sal = 1
ORDER BY salary DESC;


-- Generate a report of students, their emails, and exclude duplicate student record
WITH sc AS		
			(SELECT id, student_name, email,
				ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
			FROM students)
SELECT * 
FROM sc
WHERE student_count = 1;



--------------------------------- 2. MIN / MAX VALUE FILTERING -----------------------------------
CREATE TABLE sales (
    id INT PRIMARY KEY,
    sales_rep VARCHAR(50),
    date DATE,
    sales INT
);

INSERT INTO sales (id, sales_rep, date, sales) VALUES 
    (1, 'Emma', '2024-08-01', 6),
    (2, 'Emma', '2024-08-02', 17),
    (3, 'Jack', '2024-08-02', 14),
    (4, 'Emma', '2024-08-04', 20),
    (5, 'Jack', '2024-08-05', 5),
    (6, 'Emma', '2024-08-07', 1);

-- View the sales table
SELECT * FROM sales;


-- Return the number of sales amount on most recent date
-- Approach one (GROUP BY):
WITH rd AS (SELECT sales_rep, MAX(date) AS most_recent_date
			FROM sales
			GROUP BY sales_rep)
SELECT rd.sales_rep, rd.most_recent_date, s.sales
FROM rd LEFT JOIN sales s
	 ON rd.sales_rep = s.sales_rep
	 AND rd.most_recent_date = s.date;

-- Approach two:
SELECT * FROM
			(SELECT sales_rep, date, sales,
					ROW_NUMBER() OVER(PARTITION BY sales_rep ORDER BY date DESC) AS row_num
			FROM sales)
WHERE row_num = 1;


-- Create a report of each student with their highest grade for the semester, as well as which class they were in
WITH tg AS   (SELECT s.id, s.student_name, MAX(sg.final_grade) AS top_grade
				 FROM students s INNER JOIN student_grades sg
					ON s.id = sg.student_id
				 GROUP BY s.id, s.student_name)
SELECT tg.student_name, tg.top_grade, sg.class_name
FROM tg LEFT JOIN student_grades sg
			ON tg.id = sg.student_id AND tg.top_grade = sg.final_grade
;

-- Alternatively
WITH cte AS (
    SELECT
        s.id,
        s.student_name,
        sg.class_name,
        sg.final_grade,
        DENSE_RANK() OVER (
            PARTITION BY s.id
            ORDER BY sg.final_grade DESC
        ) AS grade_rank
    FROM students s
    INNER JOIN student_grades sg
        ON s.id = sg.student_id
)
SELECT
    student_name,
    final_grade AS top_grade,
    class_name
FROM cte
WHERE grade_rank = 1;


--------------------------------- 3. PIVOTING -----------------------------------
-- It let us transform rows into columns to summarize data in SQL
-- This can be achieved using the CASE statement

CREATE TABLE pizza_table (
    category VARCHAR(50),
    crust_type VARCHAR(50),
    pizza_name VARCHAR(100),
    price DECIMAL(5, 2)
);

INSERT INTO pizza_table (category, crust_type, pizza_name, price) VALUES
    ('Chicken', 'Gluten-Free Crust', 'California Chicken', 21.75),
    ('Chicken', 'Thin Crust', 'Chicken Pesto', 20.75),
    ('Classic', 'Standard Crust', 'Greek', 21.50),
    ('Classic', 'Standard Crust', 'Hawaiian', 19.50),
    ('Classic', 'Standard Crust', 'Pepperoni', 18.75),
    ('Supreme', 'Standard Crust', 'Spicy Italian', 22.75),
    ('Veggie', 'Thin Crust', 'Five Cheese', 18.50),
    ('Veggie', 'Thin Crust', 'Margherita', 19.50),
    ('Veggie', 'Gluten-Free Crust', 'Garden Delight', 21.50);

-- View the pizza table
SELECT * FROM pizza_table;


-- Create a summary table by pivoting the crust type column in the pizza table
SELECT category,
	SUM(CASE WHEN crust_type = 'Standard Crust' THEN 1 ELSE 0 END) AS standard_crust,
	SUM(CASE WHEN crust_type = 'Thin Crust' THEN 1 ELSE 0 END) AS standard_crust,
	SUM(CASE WHEN crust_type = 'Gluten-Free Crust' THEN 1 ELSE 0 END) AS standard_crust
FROM pizza_table
GROUP BY category;



-- Create a summary table that shows the average grade for each department and grade level

SELECT sg.department,
	ROUND(AVG(CASE WHEN s.grade_level = 9 THEN sg.final_grade END)) AS freshman,
	ROUND(AVG(CASE WHEN s.grade_level = 10 THEN sg.final_grade END))AS sophomore,
	ROUND(AVG(CASE WHEN s.grade_level = 11 THEN sg.final_grade END)) AS junior,
	ROUND(AVG(CASE WHEN s.grade_level = 9 THEN sg.final_grade END)) AS senior
FROM students s LEFT JOIN student_grades sg
ON s.id = sg.student_id
WHERE sg.department IS NOT NULL
GROUP BY sg.department
ORDER BY sg.department
;


/* --------------------------------- 4. ROLLING CALCULATIONS -----------------------------------
 They include subtotals, cumulative sums, and moving averages and 
 they allow us to perform calculations across rows of data
*/

-- Create a pizza orders table
CREATE TABLE pizza_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_date DATE,
    pizza_name VARCHAR(100),
    price DECIMAL(5, 2)
);

INSERT INTO pizza_orders (order_id, customer_name, order_date, pizza_name, price) VALUES
    (1, 'Jack', '2024-12-01', 'Pepperoni', 18.75),
    (2, 'Jack', '2024-12-02', 'Pepperoni', 18.75),
    (3, 'Jack', '2024-12-03', 'Pepperoni', 18.75),
    (4, 'Jack', '2024-12-04', 'Pepperoni', 18.75),
    (5, 'Jack', '2024-12-05', 'Spicy Italian', 22.75),
    (6, 'Jill', '2024-12-01', 'Five Cheese', 18.50),
    (7, 'Jill', '2024-12-03', 'Margherita', 19.50),
    (8, 'Jill', '2024-12-05', 'Garden Delight', 21.50),
    (9, 'Jill', '2024-12-05', 'Greek', 21.50),
    (10, 'Tom', '2024-12-02', 'Hawaiian', 19.50),
    (11, 'Tom', '2024-12-04', 'Chicken Pesto', 20.75),
    (12, 'Tom', '2024-12-05', 'Spicy Italian', 22.75),
    (13, 'Jerry', '2024-12-01', 'California Chicken', 21.75),
    (14, 'Jerry', '2024-12-02', 'Margherita', 19.50),
    (15, 'Jerry', '2024-12-04', 'Greek', 21.50);
    
-- View the table
-- View the table
SELECT * FROM pizza_orders;


-- 1. Calculate the sales subtotals for each customer
SELECT
    COALESCE(customer_name, 'ALL CUSTOMERS') AS customer_name,
    COALESCE(order_date::text, 'ALL DATES') AS order_date,
    SUM(price) AS total_sales
FROM pizza_orders
GROUP BY ROLLUP (customer_name, order_date)
ORDER BY customer_name, order_date;


-- 2. Calculate the cumulative sum of sales over time
WITH ts AS (
    SELECT
        order_date,
        SUM(price) AS total_sales
    FROM pizza_orders
    GROUP BY order_date
)
SELECT
    order_date,
    SUM(total_sales) OVER (ORDER BY order_date) AS cumulative_sum
FROM ts;


-- 3. Calculate the 3-year moving average of happiness scores for each country
SELECT	 country, year, happiness_score,
		 ROUND(AVG(happiness_score)
         OVER (PARTITION BY country ORDER BY year
			   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 3) AS row_num
FROM 	 happiness_scores
ORDER BY country, year;


/* Generate a report for total sales for each month, as well as the 
cumulative sum of sales and the six-month moving average of sales */

WITH ms AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS yr,
        EXTRACT(MONTH FROM o.order_date) AS mnth,
        SUM(o.units * p.unit_price) AS total_sales
    FROM orders o
    LEFT JOIN products p
        ON o.product_id = p.product_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
)
SELECT
    yr,
    mnth,
    total_sales,
    ROW_NUMBER() OVER (ORDER BY yr, mnth) AS rn,
    SUM(total_sales) OVER (
        ORDER BY yr, mnth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum,
    AVG(total_sales) OVER (
        ORDER BY yr, mnth
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS six_month_ma
FROM ms
ORDER BY yr, mnth;



/* --------------------------------- 5. IMPUTING NULL VALUES -----------------------------------
This means replacing NULL values in the data with other values

-- Let's replace the NULL values in the stock price column 4 different ways (aka imputation)
-- 1. With a hard coded value (integer)
-- 2. With Average of a column (subquery)
-- 3. With Prior row's value (one window function)
-- 4. With Smoothed value (two window functions)
*/

-- Create a stock prices table
CREATE TABLE IF NOT EXISTS stock_prices (
    date DATE PRIMARY KEY,
    price DECIMAL(10, 2)
);

INSERT INTO stock_prices (date, price) VALUES
	('2024-11-01', 678.27),
	('2024-11-03', 688.83),
	('2024-11-04', 645.40),
	('2024-11-06', 591.01); 

-- Replacing the NULL values
WITH RECURSIVE my_dates(dt) AS (
    SELECT DATE '2024-11-01'
    UNION ALL
    SELECT dt + 1
    FROM my_dates
    WHERE dt < DATE '2024-11-06'
),
sp AS (
    SELECT
        md.dt,
        stock_prices.price
    FROM my_dates md
    LEFT JOIN stock_prices
        ON md.dt = stock_prices.date
)
SELECT dt, price,
    COALESCE(price, 600) AS updated_price_600, -- hardcoded integer
    COALESCE(price, ROUND((SELECT AVG(price) FROM sp), 2)) AS updated_price_avg, -- using average price
    COALESCE(price, LAG(price) OVER (ORDER BY dt)) AS updated_price_prior, -- using lag value
    COALESCE(price, ROUND( (LAG(price) OVER (ORDER BY dt)
                + LEAD(price) OVER (ORDER BY dt) ) / 2, 2)) AS updated_price_smooth -- average of lead and lag values
FROM sp
ORDER BY dt;



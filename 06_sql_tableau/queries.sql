/* ---------------------- SQL + TABLEAU BUSINESS TASKS -------------------- */

/* TASK 1. Create a visualization that provides a breakdown between the male and female employees 
working in the company each year, starting from 1990. */

WITH employee_years AS (
    SELECT
        e.emp_no,
        e.gender,
        DATE_PART('year', d.from_date)::int AS calendar_year
    FROM t_employees e
    JOIN t_dept_emp d
        ON d.emp_no = e.emp_no
)
SELECT
    calendar_year,
    gender,
    COUNT(emp_no) AS num_of_employees
FROM employee_years
WHERE calendar_year >= 1990
GROUP BY calendar_year, gender
ORDER BY calendar_year, gender;


/* TASK 2. Compare the number of male managers to the number of female managers
   from different departments for each year, starting from 1990. */
WITH calendar_years AS (
    SELECT DISTINCT
        DATE_PART('year', hire_date)::int AS calendar_year
    FROM t_employees
    WHERE DATE_PART('year', hire_date)::int >= 1990
),
manager_records AS (
    SELECT
        d.dept_name, ee.gender,
        dm.emp_no, dm.from_date, dm.to_date, 
		cy.calendar_year,
        CASE
            WHEN DATE_PART('year', dm.from_date)::int <= cy.calendar_year
             AND DATE_PART('year', dm.to_date)::int >= cy.calendar_year
            THEN 1 ELSE 0
        END AS active
    FROM calendar_years cy CROSS JOIN t_dept_manager dm
    JOIN t_departments d ON dm.dept_no = d.dept_no
    JOIN t_employees ee ON dm.emp_no = ee.emp_no
)
SELECT
    dept_name, gender, emp_no, from_date,
    to_date, calendar_year, active
FROM manager_records
ORDER BY emp_no, calendar_year;



/* TASK 3. Compare the average salary of female versus male employees in the entire company
until year 2002, and add a filter allowing you to see that per each department. */

WITH avg_salary AS (SELECT 
					DATE_PART('year', s.from_date) AS calender_year,
					e.gender, 
					d.dept_name,
					ROUND(AVG(s.salary), 2) AS avg_salary
					FROM t_employees e 
				INNER JOIN t_salaries s
						ON e.emp_no = s.emp_no
				INNER JOIN t_dept_emp te
						ON s.emp_no = te.emp_no
				INNER JOIN t_departments d
						ON te.dept_no = d.dept_no
				GROUP BY e.gender, d.dept_name, calender_year
				HAVING DATE_PART('year', s.from_date) <= 2002
				ORDER BY d.dept_name
				)
SELECT * 
FROM avg_salary;



/* TASK 4. Create an SQL stored procedure that will allow you to obtain the average 
male and female salary per department within a certain salary range. 
Let this range be defined by two values the user can insert when calling the procedure.

Finally, visualize the obtained result-set in Tableau as a double bar chart. */
DROP FUNCTION IF EXISTS filter_salary(NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION filter_salary(
    p_min_salary NUMERIC,
    p_max_salary NUMERIC
)
RETURNS TABLE (
    dept_name VARCHAR(40),
    gender VARCHAR(1),
    avg_salary NUMERIC
)
LANGUAGE plpgsql
AS $func$
BEGIN
    RETURN QUERY
    SELECT d.dept_name, e.gender,
        ROUND(AVG(s.salary)::numeric, 2) AS avg_salary
    FROM t_salaries s
    JOIN t_employees e ON s.emp_no = e.emp_no
    JOIN t_dept_emp de ON de.emp_no = s.emp_no
      					AND s.from_date BETWEEN de.from_date AND de.to_date
    JOIN t_departments d ON d.dept_no = de.dept_no
    					WHERE s.salary BETWEEN p_min_salary AND p_max_salary
    GROUP BY d.dept_name, e.gender
    ORDER BY d.dept_name, e.gender;
END;
$func$;

SELECT * 
FROM filter_salary(50000, 90000);



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
        d.dept_name,
        ee.gender,
        dm.emp_no,
        dm.from_date,
        dm.to_date,
        cy.calendar_year,
        CASE
            WHEN DATE_PART('year', dm.from_date)::int <= cy.calendar_year
             AND DATE_PART('year', dm.to_date)::int >= cy.calendar_year
            THEN 1
            ELSE 0
        END AS active
    FROM calendar_years cy
    CROSS JOIN t_dept_manager dm
    JOIN t_departments d
        ON dm.dept_no = d.dept_no
    JOIN t_employees ee
        ON dm.emp_no = ee.emp_no
)
SELECT
    dept_name,
    gender,
    emp_no,
    from_date,
    to_date,
    calendar_year,
    active
FROM manager_records
ORDER BY emp_no, calendar_year;



/* TASK 3. Compare the average salary of female versus male employees in the entire company
until year 2002, and add a filter allowing you to see that per each department. */





/* TASK 4. Create a visualization that provides a breakdown between the male and female employees 
working in the company each year, starting from 1990. */


/* TASK 5. Create a visualization that provides a breakdown between the male and female employees 
working in the company each year, starting from 1990. */


SELECT * FROM t_departments;
SELECT * FROM t_dept_emp;
SELECT * FROM t_employees;
SELECT * FROM t_salaries;
SELECT * FROM t_dept_manager;


-- Questions: 

--1. Find the longest ongoing project for each department.

--2. Find all employees who are not managers.

--3. Find all employees who have been hired after the start of a project in their department.

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

-- Answers:
--1. Find the longest ongoing project for each department;

SELECT
    departments.id,
    departments.name AS department_name,
    projects.name AS project_name,
    projects.start_date,
    projects.end_date
FROM
    departments
JOIN
    projects ON departments.id = projects.department_id
WHERE
    projects.end_date IS NULL
    OR projects.end_date > GETDATE()
GROUP BY
    departments.id, departments.name, projects.name, projects.start_date, projects.end_date
HAVING
    DATEDIFF(DAY, MIN(projects.start_date), GETDATE()) = 
        MAX(DATEDIFF(DAY, projects.start_date, GETDATE()));

--2. Find all employees who are not managers;

SELECT *
FROM employees
WHERE job_title <> 'Manager';

--3. Find all employees who have been hired after the start of a project in their department;

SELECT e.*
FROM employees e
JOIN projects p ON e.department_id = p.department_id
WHERE e.hire_date > p.start_date;

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank);

SELECT
    department_id,
    employees.id,
    name,
    hire_date,
    RANK() OVER (PARTITION BY department_id ORDER BY hire_date) AS hire_rank
FROM
    employees
ORDER BY
    department_id, hire_rank;

--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department;

SELECT
    department_id,
    employees.id,
    name,
    hire_date,
    LEAD(hire_date) OVER (PARTITION BY department_id ORDER BY hire_date) AS next_hire_date,
    DATEDIFF(DAY, hire_date, LEAD(hire_date) OVER (PARTITION BY department_id ORDER BY hire_date)) AS duration
FROM
    employees
ORDER BY
    department_id, hire_date;
/* NOTE:if an employee is the last hired in their department, the duration will be NULL for that employee since, 
there is no subsequent hire date to compare with. */
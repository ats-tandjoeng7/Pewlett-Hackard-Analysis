-- Module 7 Challenge (by Parto Tandjoeng)
-- Creating tables for PH_EmployeesDB named departments
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL,
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);
-- Creating tables for PH_EmployeesDB named employees
CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL,
	PRIMARY KEY (emp_no)
);
-- Creating tables for PH_EmployeesDB named dept_manager
CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (dept_no, emp_no)
);
-- Creating tables for PH_EmployeesDB named salaries
CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);
-- Creating tables for PH_EmployeesDB named dept_employee
CREATE TABLE dept_employee (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
-- Creating tables for PH_EmployeesDB named titles
CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);
-- Import data of each table in the following order
-- Import csv files departments.csv
SELECT * FROM departments;
-- Import csv files employees.csv
SELECT * FROM employees;
-- Import csv files dept_manager.csv
SELECT * FROM dept_manager;
-- Import csv files salaries.csv
SELECT * FROM salaries;
-- Import csv files dept_emp.csv
SELECT * FROM dept_employee;
-- Import csv files titles.csv
SELECT * FROM titles;

-- Delete/drop a table and specified relationships completely from the database
-- DROP TABLE dept_employee CASCADE;
-- DROP TABLE titles CASCADE;
-- Search for employees who were born between 1952 and 1955
CREATE FUNCTION startd() RETURNS date AS $$
DECLARE
    startd date := '1952-01-01';
BEGIN
--     RAISE NOTICE 'start date %', startd;
	RETURN startd;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION endd() RETURNS date AS $$
DECLARE
    endd date := '1955-12-31';
BEGIN
--     RAISE NOTICE 'end date %', endd;
	RETURN endd;
END;
$$ LANGUAGE plpgsql;

SELECT startd();
SELECT endd();

CREATE PROCEDURE retiree_list() AS '
	SELECT first_name, last_name
	FROM employees
	WHERE (birth_date BETWEEN startd() AND endd());
' LANGUAGE SQL;
CALL retiree_list();

SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN startd() AND endd());

-- Search for employees who were born in 1952
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- Search for employees who were born in 1953
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31'

-- Search for employees who were born in 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31'

-- Search for employees who were born in 1954
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31'

-- Generate a table containing employees who were born between 1952-1955 within certain hire date
-- DROP TABLE retirement_info CASCADE;
-- DROP TABLE retirement_info;
-- SELECT COUNT(first_name)
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table
SELECT * FROM retirement_info;

SELECT d.dept_name, 
	dm.emp_no, 
	dm.from_date, 
	dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm
ON d.dept_no = dm.dept_no;

-- Without using aliases
/*
SELECT retirement_info.emp_no, retirement_info.first_name, retirement_info.last_name, dept_employee.to_date
FROM retirement_info
LEFT JOIN dept_employee
ON retirement_info.emp_no = dept_employee.emp_no;
*/

SELECT ri.emp_no, 
	ri.first_name, 
	ri.last_name, 
	de.to_date
FROM retirement_info AS ri
LEFT JOIN dept_employee AS de
ON ri.emp_no = de.emp_no;

-- List of current employees
SELECT ri.emp_no, 
	ri.first_name, 
	ri.last_name, 
	de.to_date
INTO current_emp
FROM retirement_info AS ri
	LEFT JOIN dept_employee AS de
	ON ri.emp_no = de.emp_no
WHERE de.to_date = '9999-01-01';

-- Check the table
SELECT * FROM current_emp;

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
FROM current_emp AS ce
	LEFT JOIN dept_employee AS de
	ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM salaries
-- ORDER BY to_date DESC;
ORDER BY to_date ASC;

-- List of employee info
SELECT e.emp_no, 
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
	INNER JOIN salaries AS s
		ON e.emp_no = s.emp_no
	INNER JOIN dept_employee AS de
		ON e.emp_no = de.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');

-- Check the table
SELECT * FROM emp_info;

-- List of managers per department
SELECT dm.dept_no,
	d.dept_name,
	dm.emp_no, 
	ce.last_name,
	ce.first_name,
	dm.from_date,
	dm.to_date
INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON dm.dept_no = d.dept_no
	INNER JOIN current_emp AS ce
		ON dm.emp_no = ce.emp_no;

-- Check the table
SELECT * FROM manager_info;

-- List of retirees per department
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp AS ce
	INNER JOIN dept_employee AS de
		ON ce.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no;

-- Check the table
SELECT * FROM dept_info;

-- Total employees in each team
SELECT COUNT(emp_no),
	dept_name
FROM dept_info
GROUP BY dept_name
ORDER BY dept_name ASC;

-- List of employees for the Sales teams
SELECT *
FROM dept_info
WHERE dept_name = 'Sales';

-- List of employees for the Development and Sales teams
SELECT *
FROM dept_info
WHERE dept_name = 'Sales' OR dept_name = 'Development';

SELECT *
FROM dept_info
WHERE dept_name IN ('Development', 'Sales');

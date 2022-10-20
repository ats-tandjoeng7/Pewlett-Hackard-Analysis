-- Create list of titles of all retiring employees
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	tt.title,
	tt.from_date,
	tt.to_date
INTO retirement_titles
FROM employees AS e
	INNER JOIN titles AS tt
		ON e.emp_no = tt.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY e.emp_no ASC;

-- Use Dictinct with Order By to remove duplicate rows
SELECT DISTINCT ON (emp_no) emp_no,
	first_name,
	last_name,
	title
INTO unique_titles
FROM retirement_titles
WHERE (to_date = '9999-01-01')
ORDER BY emp_no, first_name DESC;

-- Total number of retiring titles in descending order
SELECT COUNT(emp_no),
	title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY count DESC;

-- Check the tables
SELECT * FROM retirement_titles;
SELECT * FROM unique_titles;
SELECT * FROM retiring_titles;

-- Deliverable 2
-- Double check the joined tables before filtering
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
	tt.title
FROM employees AS e
	INNER JOIN dept_employee AS de
		ON e.emp_no = de.emp_no
	INNER JOIN titles AS tt
		ON e.emp_no = tt.emp_no
WHERE (e.emp_no = '10095'
	OR e.emp_no = '10122'
	OR e.emp_no = '10291'
	OR e.emp_no = '10476'
	OR e.emp_no = '10663'
	OR e.emp_no = '10762')
ORDER BY e.emp_no ASC;

-- Create unique titles of employees eligible for the mentorship
SELECT DISTINCT ON (e.emp_no) e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
	tt.title
INTO mentorship_eligibility
FROM employees AS e
	INNER JOIN dept_employee AS de
		ON e.emp_no = de.emp_no
	INNER JOIN titles AS tt
		ON e.emp_no = tt.emp_no
WHERE (de.to_date = '9999-01-01')
	AND (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY e.emp_no ASC;
-- Check the table
SELECT * FROM mentorship_eligibility;

-- Deliverable 3
-- Total number of mentorship-eligible titles in descending order
DROP TABLE IF EXISTS mentoring_titles CASCADE;
SELECT COUNT(emp_no),
	title
INTO mentoring_titles
FROM mentorship_eligibility
GROUP BY title
ORDER BY count DESC;
-- Check the table
SELECT * FROM mentoring_titles;

-- Change identical column names before joining
ALTER TABLE mentoring_titles
RENAME COLUMN count TO mentee_count;
ALTER TABLE mentoring_titles
RENAME COLUMN title TO mentee_title;
-- Create mentor-mentee difference by title table
DROP TABLE IF EXISTS mentor_mentee_diff CASCADE;
CREATE TABLE mentor_mentee_diff AS
	SELECT * FROM retiring_titles AS rt
	FULL JOIN mentoring_titles AS mt ON rt.title=mt.mentee_title;

-- Aggregate the joined table
DROP TABLE IF EXISTS workforce_gaps CASCADE;
SELECT count,
	title,
	mentee_count,
	mentee_title,
	(count-mentee_count) AS workforce_gap
INTO workforce_gaps
FROM mentor_mentee_diff;
-- Check the table
SELECT * FROM workforce_gaps;

-- Unique titles by department name
DROP TABLE IF EXISTS unique_titles_dept CASCADE;
SELECT DISTINCT ON (ut.emp_no) ut.emp_no,
	ut.first_name,
	ut.last_name,
	ut.title,
	di.dept_name
INTO unique_titles_dept
FROM unique_titles AS ut
	INNER JOIN dept_info AS di
		ON ut.emp_no = di.emp_no
ORDER BY ut.emp_no ASC;
-- Check the table
SELECT * FROM unique_titles_dept;

SELECT COUNT(emp_no),
	dept_name
FROM unique_titles_dept
GROUP BY dept_name
ORDER BY count DESC;

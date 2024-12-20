------------------------------------------------------------------------------------------------------------------------------
--Hello and welcome. Here you will see the table creation and editing tasks given to me in my first work. Let's get started.
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- <1> -- Add a field named avg_salary with data type INTEGER to the Departments table.
------------------------------------------------------------------------------------------------------------------------------
-- <2> -- Update the type of the field you added to DECIMAL(4,2).
------------------------------------------------------------------------------------------------------------------------------
-- <3> -- Update the name of the field you added to salary.
------------------------------------------------------------------------------------------------------------------------------
-- <4> -- Remove the field you created.
------------------------------------------------------------------------------------------------------------------------------
-- <5> -- Employee with ID 104 has been promoted and his salary has changed. Update her salary to 7500.00.
------------------------------------------------------------------------------------------------------------------------------
-- <6> -- Employee with ID Diana got married and changed her last name. 
-- Update her last name to “Jackson” and her e-mail to “diana.jackson@sqltutorial.org”.
------------------------------------------------------------------------------------------------------------------------------



CREATE DATABASE hr;


CREATE TABLE departments 
(
	department_id SMALLINT PRIMARY KEY,
	department_name VARCHAR (30) NOT NULL,
	location_id INTEGER
)
;


INSERT INTO departments(department_id,department_name,location_id) VALUES 
	(1,'Administration',1700),
	(2,'Marketing',1800),
	(3,'Purchasing',1700),
	(4,'Human Resources',2400),
	(5,'Shipping',1500),
	(6,'IT',1400),
	(7,'Public Relations',2700),
	(8,'Sales',2500),
	(9,'Executive',1700),
	(10,'Finance',1700),
	(11,'Accounting',1700)
;


CREATE TABLE jobs (
	job_id SMALLINT PRIMARY KEY,
	job_title CHARACTER VARYING (35) NOT NULL,
	min_salary DECIMAL (8, 2),
	max_salary DECIMAL (8, 2)
);



COPY jobs FROM 'C:/Users/MSI/Desktop/Veri Analizi/Ders Notlarım/SQL/First Work/jobs.csv' DELIMITER ',' CSV HEADER;



CREATE TABLE employees (
	employee_id INTEGER PRIMARY KEY,
	first_name CHARACTER VARYING (20),
	last_name CHARACTER VARYING (25),
	email CHARACTER VARYING (100) NOT NULL,
	phone_number CHARACTER VARYING (20),
	hire_date DATE,
	job_id INTEGER,
	salary NUMERIC (8, 2),
	manager_id INTEGER,
	department_id INTEGER,
	FOREIGN KEY (job_id) REFERENCES jobs (job_id),
	FOREIGN KEY (department_id) REFERENCES departments (department_id)
);



COPY employees FROM 'C:/Users/MSI/Desktop/Veri Analizi/Ders Notlarım/SQL/First Work/employees.csv' DELIMITER ',' CSV HEADER;


------------------------------------------------------------------------------------------------------------------------------
-- After creating the tables, determining the Primary and Foreign Keys and importing the information, 
-- I can then start to fulfill the tasks required of me.
------------------------------------------------------------------------------------------------------------------------------

-- <1> -- 
ALTER TABLE departments ADD COLUMN avg_salary INTEGER;
------------------------------------------------------------------------------------------------------------------------------

-- <2> -- 
ALTER TABLE departments ALTER avg_salary TYPE DECIMAL(4,2);
------------------------------------------------------------------------------------------------------------------------------

-- <3> -- 
ALTER TABLE departments RENAME avg_salary TO salary;

------------------------------------------------------------------------------------------------------------------------------
-- <4> -- 
ALTER TABLE departments DROP COLUMN salary;

------------------------------------------------------------------------------------------------------------------------------
-- <5> -- 
UPDATE employees SET salary = 7500.00 WHERE employee_id = 104;

------------------------------------------------------------------------------------------------------------------------------
-- <6> -- 
UPDATE employees SET last_name = 'Jackson' WHERE first_name = 'Diana';

UPDATE employees SET email = 'diana.jackson@sqltutorial.org' WHERE first_name = 'Diana';
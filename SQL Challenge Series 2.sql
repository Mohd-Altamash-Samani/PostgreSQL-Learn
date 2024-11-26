-- ============================================
-- Script for Employee and EmployeeDetail Table
-- ============================================

-- Create the Employee table with basic employee details
CREATE TABLE Employee (
    EmpID int NOT NULL,            -- Unique identifier for employees
    EmpName Varchar,               -- Name of the employee
    Gender Char,                   -- Gender of the employee ('M' or 'F')
    Salary int,                    -- Employee's salary
    City Char(20)                  -- City where the employee resides
);

-- Insert sample records into the Employee table
INSERT INTO Employee
VALUES 
    (1, 'Arjun', 'M', 75000, 'Pune'),
    (2, 'Ekadanta', 'M', 125000, 'Bangalore'),
    (3, 'Lalita', 'F', 150000 , 'Mathura'),
    (4, 'Madhav', 'M', 250000 , 'Delhi'),
    (5, 'Visakha', 'F', 120000 , 'Mathura');

-- Retrieve all records from the Employee table
SELECT * FROM Employee;

-- Create the EmployeeDetail table to store additional employee details
CREATE TABLE EmployeeDetail (
    EmpID int NOT NULL,            -- Unique identifier for employees (Foreign Key)
    Project Varchar,               -- Project assigned to the employee
    EmpPosition Char(20),          -- Position of the employee
    DOJ date                       -- Date of Joining
);

-- Insert sample records into the EmployeeDetail table
INSERT INTO EmployeeDetail
VALUES 
    (1, 'P1', 'Executive', '2019-01-26'),
    (2, 'P2', 'Executive', '2020-05-04'),
    (3, 'P1', 'Lead', '2021-10-21'),
    (4, 'P3', 'Manager', '2019-11-29'),
    (5, 'P2', 'Manager', '2020-08-01');

-- Retrieve all records from the EmployeeDetail table
SELECT * FROM EmployeeDetail;

-- ==============================
-- SQL Queries for Data Analysis
-- ==============================

-- Find employees with salaries between 200,000 and 300,000
SELECT * FROM Employee
WHERE Salary BETWEEN 200000 AND 300000;

-- Retrieve employees from the same city
SELECT e1.*, e2.*
FROM Employee e1
JOIN Employee e2
    ON e1.City = e2.City
WHERE e1.EmpID != e2.EmpID;

-- Check for null values in the Employee table
SELECT * FROM Employee
WHERE EmpID IS NULL;

-- Find the cumulative sum of employee salaries
SELECT *, SUM(Salary) OVER(ORDER BY EmpID) AS Cum_Sum
FROM Employee;

-- Calculate the male-to-female employee ratio
SELECT 
    COUNT(*) FILTER (WHERE Gender = 'M') * 100 / COUNT(*) AS Male_Ratio,
    COUNT(*) FILTER (WHERE Gender = 'F') * 100 / COUNT(*) AS Female_Ratio
FROM Employee;

-- Retrieve 50% of the records from the Employee table
SELECT * FROM Employee
WHERE EmpID <= (SELECT COUNT(*) / 2 FROM Employee);

-- Mask the last two digits of employee salaries
SELECT Salary,
       CONCAT(SUBSTRING(Salary::TEXT, 1, LENGTH(Salary::TEXT) - 2), 'XX') AS Masked_Salary
FROM Employee;

-- Retrieve even and odd rows from the Employee table
-- For even rows
SELECT * FROM Employee
WHERE MOD(EmpID, 2) = 0;

-- For odd rows
SELECT * FROM Employee
WHERE MOD(EmpID, 2) != 0;

-- Find employees whose names match specific patterns
-- Begin with 'A'
SELECT * FROM Employee WHERE EmpName LIKE 'A%';
-- Contains 'a' as the second letter
SELECT * FROM Employee WHERE EmpName LIKE '_a%';
-- Ends with 't' as the second last letter
SELECT * FROM Employee WHERE EmpName LIKE '%t_';
-- Ends with 'n' and has exactly 4 characters
SELECT * FROM Employee WHERE EmpName LIKE '____n';
-- Begins with 'V' and ends with 'a'
SELECT * FROM Employee WHERE EmpName LIKE 'V%a';

-- Retrieve employee names starting or ending with vowels
-- Starting with vowels
SELECT DISTINCT * FROM Employee WHERE LOWER(EmpName) SIMILAR TO '[aeiou]%';
-- Ending with vowels
SELECT DISTINCT * FROM Employee WHERE LOWER(EmpName) SIMILAR TO '%[aeiou]';
-- Starting and ending with vowels
SELECT DISTINCT * FROM Employee WHERE LOWER(EmpName) SIMILAR TO '[aeiou]%[aeiou]';

-- Find the Nth highest salary using window functions
WITH Temp AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rank
    FROM Employee
)
SELECT * FROM Temp WHERE Rank = 1;

-- Find duplicate records in the Employee table
SELECT EmpID, COUNT(EmpID) AS Duplicate_Count
FROM Employee
GROUP BY EmpID
HAVING COUNT(EmpID) > 1;

-- List employees working on the same project
WITH Combine AS (
    SELECT e.EmpID, e.EmpName, ed.Project
    FROM Employee e
    JOIN EmployeeDetail ed
        ON e.EmpID = ed.EmpID
)
SELECT c1.EmpName AS Employee1, c2.EmpName AS Employee2, c1.Project
FROM Combine c1
JOIN Combine c2
    ON c1.Project = c2.Project
WHERE c1.EmpID <> c2.EmpID AND c1.EmpName > c2.EmpName;

-- Find the highest salary for each project
SELECT ed.Project, MAX(e.Salary) AS Max_Salary
FROM Employee e
JOIN EmployeeDetail ed
    ON e.EmpID = ed.EmpID
GROUP BY ed.Project;

-- Count employees who joined each year
SELECT EXTRACT(YEAR FROM DOJ) AS JoinYear, COUNT(*) AS Employee_Count
FROM EmployeeDetail
GROUP BY JoinYear;

-- Group employees based on salary levels
SELECT EmpName, Salary,
       CASE 
           WHEN Salary > 200000 THEN 'High'
           WHEN Salary BETWEEN 100000 AND 200000 THEN 'Medium'
           WHEN Salary < 100000 THEN 'Low'
       END AS Salary_Group
FROM Employee;

-- Pivot total salary for each city
SELECT 
    SUM(CASE WHEN City = 'Mathura' THEN Salary END) AS Mathura,
    SUM(CASE WHEN City = 'Pune' THEN Salary END) AS Pune,
    SUM(CASE WHEN City = 'Delhi' THEN Salary END) AS Delhi,
    SUM(CASE WHEN City = 'Bangalore' THEN Salary END) AS Bangalore
FROM Employee;

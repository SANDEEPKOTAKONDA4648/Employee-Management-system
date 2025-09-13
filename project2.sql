create database Employee_Management_System;
show databases;
use Employee_Management_System;
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from JobDepartment;
select * from SalaryBonus;
select  * from Employee;
select * from Qualification;
select * from Leaves;
select * from Payroll;

-- Analysis Questions 
-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select  * from Employee;
SELECT COUNT(DISTINCT firstname and lastname) AS unique_name_count
FROM Employee;
-- Which departments have the highest number of employees?
select * from JobDepartment;
SELECT jobdept, COUNT(*) AS employee_count
FROM JobDepartment
GROUP BY jobdept
ORDER BY employee_count DESC
limit 2;
-- What is the average salary per department?
WITH SalaryDetails AS (
    SELECT 
        JobDept,
        (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', 1), '$', -1) AS UNSIGNED) +
         CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', -1), '$', -1) AS UNSIGNED)) / 2 AS AverageSalary
    FROM JobDepartment
)
SELECT 
    JobDept,
    AVG(AverageSalary) AS Average_Salary
FROM SalaryDetails
GROUP BY JobDept
ORDER BY Average_Salary DESC;
-- Who are the top 5 highest-paid employees?
WITH EmployeeSalaries AS (
    SELECT 
        Name,
        JobDept,
        (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', 1), '$', -1) AS UNSIGNED) +
         CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', -1), '$', -1) AS UNSIGNED)) / 2 AS AverageSalary
    FROM JobDepartment
)
SELECT 
    Name,
    JobDept,
    AverageSalary
FROM EmployeeSalaries
ORDER BY AverageSalary DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT 
    SUM(
        (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', 1), '$', -1) AS UNSIGNED) +
         CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SalaryRange, '-', -1), '$', -1) AS UNSIGNED)) / 2
    ) AS TotalSalaryExpenditure
FROM JobDepartment;



-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT JobDept, COUNT(DISTINCT Name) AS UniqueJobRoles
FROM JobDepartment
GROUP BY JobDept;
-- 2. What is the average salary range per department?
SELECT 
    JobDept,
    AVG(CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', 1), '$', '') AS UNSIGNED)) AS AvgMinSalary,
    AVG(CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', -1), '$', '') AS UNSIGNED)) AS AvgMaxSalary,
    AVG((CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', 1), '$', '') AS UNSIGNED) + 
         CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', -1), '$', '') AS UNSIGNED)) / 2) AS AvgSalary
FROM JobDepartment
GROUP BY JobDept;

-- 3. Which job roles offer the highest salary?

SELECT 
    Name, 
    JobDept, 
    CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', -1), '$', '') AS UNSIGNED) AS MaxSalary
FROM JobDepartment
ORDER BY MaxSalary DESC
LIMIT 5;

-- 4. Which departments have the highest total salary allocation?

SELECT 
    JobDept, 
    SUM((CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', 1), '$', '') AS UNSIGNED) + 
         CAST(REPLACE(SUBSTRING_INDEX(SalaryRange, ' - ', -1), '$', '') AS UNSIGNED)) / 2) AS TotalSalaryAllocation
FROM JobDepartment
GROUP BY JobDept
ORDER BY TotalSalaryAllocation DESC;

select * from Qualification;
DESCRIBE Qualification;
-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- 1. How many employees have at least one qualification listed?

SELECT COUNT(DISTINCT Emp_ID) AS EmployeesWithQualification
FROM Qualification
WHERE Requirements IS NOT NULL;

-- 2. Which positions require the most qualifications?
SELECT Position, COUNT(Requirements) AS QualificationCount
FROM Qualification
GROUP BY Position
ORDER BY QualificationCount DESC
LIMIT 1;

-- Which employees have the highest number of qualifications?
SELECT Emp_ID, COUNT(*) AS QualificationCount
FROM Qualification
GROUP BY Emp_ID
HAVING QualificationCount = (
    SELECT MAX(QualCount)
    FROM (
        SELECT COUNT(*) AS QualCount
        FROM Qualification
        GROUP BY Emp_ID
    ) AS SubQuery
);

-- 4. LEAVE AND ABSENCE PATTERNS

 -- Which year had the most employees taking leaves?
 select * from leaves;
 select * from JobDepartment;
 SELECT 
    YEAR(Date) AS Year, 
    COUNT(DISTINCT emp_ID) AS EmployeesOnLeave
FROM Leaves
GROUP BY YEAR(Date)
ORDER BY EmployeesOnLeave DESC
LIMIT 1;
-- What is the average number of leave days taken by its employees per department?
select * from employee;
SELECT 
    e.emp_ID, 
    COUNT(l.leave_ID) / COUNT(DISTINCT l.emp_ID) AS AvgLeavesPerEmployee
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
GROUP BY e.emp_ID;
-- Which employees have taken the most leaves?
SELECT 
    emp_ID, 
    COUNT(*) AS TotalLeaves
FROM Leaves
GROUP BY emp_ID
ORDER BY TotalLeaves DESC;
-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS TotalLeaveDays
FROM Leaves;
 -- How do leave days correlate with payroll amounts?
 select * from leaves;

SELECT 
    l.emp_ID,
    COUNT(l.leave_ID) AS TotalLeaveDays,
    p.salary_ID
FROM Leaves l
JOIN Payroll p ON l.emp_ID = p.emp_ID
GROUP BY l.emp_ID, p.salary_ID;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
 select * from payroll;
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    SUM(total_amount) AS MonthlyPayroll
FROM Payroll
GROUP BY Month
ORDER BY Month;

-- What is the average bonus given per department?
select * from employee;
select * from SalaryBonus;
SELECT 
    salary_ID,
    ROUND(AVG(bonus), 2) AS AvgBonus
FROM SalaryBonus
GROUP BY salary_ID
ORDER BY AvgBonus DESC;
--  3. Which Department Receives the Highest Total Bonuses
SELECT 
    Job_ID,
    SUM(bonus) AS TotalBonus
FROM SalaryBonus
GROUP BY Job_ID
ORDER BY TotalBonus DESC
LIMIT 1;


select * from Payroll;
select * from Leaves;
show tables;
select * from employee;
select * from jobdepartment;
select * from salarybonus;
-- 4 What is the average value of total_amount after considering leave deductions?
SELECT AVG(p.total_amount - (p.salary_ID / 30) * l.leave_ID) AS AvgAdjustedTotal
FROM Payroll p
JOIN Leaves l ON p.emp_ID = l.emp_ID;

-- 6. EMPLOYEE PERFORMANCE AND GROWTH

-- Which year had the highest number of employee promotions?
SELECT 
    YEAR(Date_In) AS PromotionYear,
    COUNT(*) AS PromotionCount
FROM 
    Qualification
GROUP BY 
    YEAR(Date_In)
ORDER BY 
    PromotionCount DESC
LIMIT 1;









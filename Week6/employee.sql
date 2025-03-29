CREATE TABLE employees (
    EmployeeID BIGINT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    BirthDate DATE,
    Gender VARCHAR(10),
    HireDate DATE,
    Department VARCHAR(100),
    JobTitle VARCHAR(100),
    Salary INT,
    ManagerID BIGINT,  -- Self-referencing for hierarchical relationships
    Email VARCHAR(255),
    PhoneNumber VARCHAR(20),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    EmploymentType VARCHAR(50) CHECK (EmploymentType IN ('Full-Time', 'Part-Time', 'Contract')),
    Status VARCHAR(50) CHECK (Status IN ('Active', 'On Leave', 'Terminated'))
);

INSERT INTO employees (EmployeeID, FirstName, LastName, BirthDate, Gender, HireDate, Department, JobTitle, Salary, ManagerID, Email, PhoneNumber, Address, City, State, Country, EmploymentType, Status)
VALUES
(1, 'John', 'Doe', '1985-03-25', 'Male', '2015-06-01', 'Engineering', 'Software Engineer', 90000, NULL, 'john.doe@example.com', '555-1234', '123 Elm St', 'New York', 'NY', 'USA', 'Full-Time', 'Active'),
(2, 'Jane', 'Smith', '1990-07-15', 'Female', '2018-02-01', 'Marketing', 'Marketing Manager', 85000, 1, 'jane.smith@example.com', '555-5678', '456 Oak St', 'Chicago', 'IL', 'USA', 'Full-Time', 'Active'),
(3, 'Alex', 'Johnson', '1980-11-10', 'Male', '2010-04-25', 'Engineering', 'Senior Developer', 120000, 1, 'alex.johnson@example.com', '555-8765', '789 Pine St', 'Los Angeles', 'CA', 'USA', 'Full-Time', 'Active'),
(4, 'Emily', 'Davis', '1992-02-20', 'Female', '2020-05-15', 'Human Resources', 'HR Specialist', 65000, 2, 'emily.davis@example.com', '555-4321', '321 Maple St', 'San Francisco', 'CA', 'USA', 'Part-Time', 'Active'),
(5, 'Michael', 'Lee', '1983-09-30', 'Male', '2012-03-10', 'Engineering', 'Lead Engineer', 135000, 1, 'michael.lee@example.com', '555-3456', '654 Cedar St', 'Austin', 'TX', 'USA', 'Full-Time', 'On Leave'),
(6, 'Sarah', 'Martinez', '1995-01-01', 'Female', '2021-08-20', 'Sales', 'Sales Associate', 50000, 2, 'sarah.martinez@example.com', '555-6789', '987 Birch St', 'Miami', 'FL', 'USA', 'Contract', 'Active');

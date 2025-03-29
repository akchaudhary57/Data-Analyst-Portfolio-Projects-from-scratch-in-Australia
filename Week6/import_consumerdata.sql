use bronze


Drop table if exists rtemp_comsumer;
-------------------------------------------------------------------------------
GO
-------------------------------------------------------------------------------
create table rtemp_comsumer 
(
	CustomerKey varchar(200),
	Prefix varchar(200),
	FirstName varchar(200),
	LastName varchar(200),
	BirthDate varchar(200),
	MaritalStatus varchar(200),
	Gender varchar(200),
	EmailAddress varchar(200),
	Salary varchar(200),
	TotalChildren varchar(200),
	EducationLevel varchar(200),
	Occupation varchar(200),
	HomeOwner varchar(200)
)

Declare @sourcefilename varchar(200) 

select @sourcefilename = 'C:\Users\AjitC\Desktop\Click Consulting\Sales Data\Customers.csv'

-------------------------------------------------------------------------------
-- IMPORT DATA USING BULK INSERT
-------------------------------------------------------------------------------
BULK INSERT rtemp_comsumer
FROM 'C:\Users\AjitC\Desktop\Click Consulting\Sales Data\Customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',
	FORMAT = 'CSV',
	FIELDQUOTE = '"' 
)

Drop table if exists rstage_customer;

create table rstage_customer 
(
	CustomerKey varchar(200),
	Prefix varchar(200),
	FirstName varchar(200),
	LastName varchar(200),
	BirthDate varchar(200),
	MaritalStatus varchar(200),
	Gender varchar(200),
	EmailAddress varchar(200),
	Salary varchar(200),
	TotalChildren varchar(200),
	EducationLevel varchar(200),
	Occupation varchar(200),
	HomeOwner varchar(200),
	sourcefilename varchar(200)
)

insert into rstage_customer
select 
	LTRIM(RTRIM(CustomerKey)) as CustomerKey,
	LTRIM(RTRIM(Prefix)) as Prefix,
	LTRIM(RTRIM(FirstName)) as FirstName,
	LTRIM(RTRIM(LastName)) as LastName,
	LTRIM(RTRIM(BirthDate)) as BirthDate,
	LTRIM(RTRIM(MaritalStatus)) as MaritalStatus,
	LTRIM(RTRIM(Gender)) as Gender,
	LTRIM(RTRIM(EmailAddress)) as EmailAddress,
	LTRIM(RTRIM(Salary)) as Salary,
	LTRIM(RTRIM(TotalChildren)) as TotalChildren,
	LTRIM(RTRIM(EducationLevel)) as EducationLevel,
	LTRIM(RTRIM(Occupation)) as Occupation,
	LTRIM(RTRIM(HomeOwner)) as HomeOwner,
	@sourcefilename
from 
	rtemp_comsumer

Drop table if exists raw_customer;

create table raw_customer 
(
CustomerKey bigint,
Prefix varchar(200),
FirstName varchar(200),
LastName varchar(200),
BirthDate date,
MaritalStatus varchar(200),
Gender varchar(200),
EmailAddress varchar(200),
Salary int,
TotalChildren varchar(200),
EducationLevel varchar(200),
Occupation varchar(200),
HomeOwner varchar(200),
sourcefilename varchar(200)
)

insert into raw_customer
select CustomerKey,
Prefix,
FirstName,
LastName,
BirthDate,
MaritalStatus,
Gender,
EmailAddress,
replace(replace(Salary,'$',''),',','') as Salary,
TotalChildren,
EducationLevel,
Occupation,
HomeOwner,
sourcefilename
 from rstage_customer

 select * From raw_customer

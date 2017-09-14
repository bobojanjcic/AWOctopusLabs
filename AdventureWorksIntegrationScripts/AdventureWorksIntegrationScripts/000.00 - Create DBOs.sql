
ALTER PROCEDURE dbo.Integration_SalesPerson_Create
	@SalesPerson Varchar(255)
AS 

SET XACT_ABORT, NOCOUNT ON;

BEGIN TRANSACTION 


DECLARE @BusinessEntityID INT 
	, @now DATETIME = GETUTCDATE()
	, @FirstName varchar(50)
	, @LastName varchar(50)

INSERT INTO [Person].[BusinessEntity]
(
	[ModifiedDate]
)
SELECT
	@now;
	

SET @BusinessEntityID = SCOPE_IDENTITY(); 
SET @FirstName = LEFT(@SalesPerson, CHARINDEX(' ', @SalesPerson)) 
SET @LastName = RIGHT(@SalesPerson, CHARINDEX(' ', @SalesPerson) + 2) 

INSERT INTO Person.Person 
(
	[BusinessEntityID]
	, [PersonType]
	, [FirstName]
	, [LastName]
)

SELECT 
	@BusinessEntityID
	, 'EM'
	, @FirstName
	, @LastName;

COMMIT TRANSACTION;
GO

ALTER PROCEDURE dbo.Integration_ProductionProduct_Insert
	@ProductName [dbo].[Name]
	, @ProductId INT OUTPUT
AS 

SET XACT_ABORT, NOCOUNT ON;

BEGIN TRANSACTION 

DECLARE @now datetime2(0) = GETUTCDATE();

INSERT INTO Production.Product 
(
	[Name]
	, ProductNumber
	, SafetyStockLevel
	, ReorderPoint
	, StandardCost
	, ListPrice
	, DaysToManufacture
	, SellStartDate
) 

SELECT 
	@ProductName
	, CONCAT('XX-', CAST(CAST(RAND() * 1000 AS INT) AS VARCHAR))
	, 2
	, 1
	, 0
	, 0
	, 1
	, @now

SET @ProductId = SCOPE_IDENTITY();

COMMIT TRANSACTION;

GO

ALTER PROCEDURE dbo.Integration_Sales_Ingest
	@ProductName [dbo].[Name]
	, @SalesPerson varchar(255)
AS 

DECLARE @ProductId INT 

IF NOT EXISTS( SELECT 1 
FROM 
	Person.Person p 
WHERE 
	CONCAT(p.FirstName, p.MiddleName, p.LastName) = @SalesPerson)
BEGIN 
	EXEC dbo.Integration_SalesPerson_Create @SalesPerson = @SalesPerson;
END 

IF NOT EXISTS( SELECT 1 
FROM 
	Production.Product p 
WHERE 
	p.Name = @ProductName)
BEGIN 
	EXEC dbo.Integration_ProductionProduct_Insert  @ProductName = @ProductName, @ProductId = @ProductId OUTPUT;
END 
GO



ALTER PROCEDURE dbo.Integration_SalesPerson_Create
	@SalesPerson Varchar(255)
AS 

SET XACT_ABORT, NOCOUNT ON;

BEGIN TRANSACTION 

DECLARE @BusinessEntityID INT 
	, @now DATETIME = GETUTCDATE()
	, @FirstName varchar(50)
	, @LastName varchar(50)

INSERT INTO [Person].[BusinessEntity]
(
	[ModifiedDate]
)
SELECT
	@now;
	

SET @BusinessEntityID = SCOPE_IDENTITY(); 
SET @FirstName = LEFT(@SalesPerson, CHARINDEX(' ', @SalesPerson)) 
SET @LastName = RIGHT(@SalesPerson, CHARINDEX(' ', @SalesPerson) + 2) 

INSERT INTO Person.Person 
(
	[BusinessEntityID]
	, [PersonType]
	, [FirstName]
	, [LastName]
)

SELECT 
	@BusinessEntityID
	, 'EM'
	, @FirstName
	, @LastName;

insert into [HumanResources].[Employee]
(
	BusinessEntityID
	, NationalIDNumber
	, LoginID
	, JobTitle 
	, BirthDate
	, MaritalStatus
	, Gender
	, HireDate
)
SELECT 
	@BusinessEntityId
	, CAST(CAST((RAND()) * 1000000000 AS INT) AS VARCHAR)
	, CONCAT('adventure-works\', @FirstName, CAST(CAST(RAND() * 100 AS INT) AS VARCHAR))
	, 'Sales Representative'
	, '1988-05-05'
	, 'M'
	, 'F'
	, @now;

COMMIT TRANSACTION



ALTER PROCEDURE dbo.Integration_Sales_Delete
	@ProductName [dbo].[Name]
	, @SalesPerson varchar(255)
AS 

DELETE s
FROM 
	dbo.Staged_Sales s
WHERE 
	s.[Product Name] = @ProductName
	AND s.[Sales Person] = @SalesPerson;
GO
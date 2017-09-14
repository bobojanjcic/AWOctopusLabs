CREATE PROCEDURE dbo.Integration_ProductionProduct_Insert
	@ProductName [dbo].[Name]
	, @ProductId INT OUTPUT
AS 

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
	, 'XX-9999'
	, 2
	, 1
	, 0
	, 0
	, 1
	, @now

SET @ProductId = SCOPE_IDENTITY();
GO

ALTER PROCEDURE dbo.Integration_Sales_Ingest
	@ProductName [dbo].[Name]
	, @SalesPerson varchar(255)
AS 

IF NOT EXISTS( SELECT 1 
FROM 
	Production.Product p 
WHERE 
	p.Name = @ProductName)
BEGIN 
	EXEC dbo.Integration_ProductionProduct_Insert  @ProductName = @ProductName
END 

IF NOT EXISTS( SELECT 1 
FROM 
	HumanResources.vEmployeeHierarchy p 
WHERE 
	p.EmployeeName  = @SalesPerson)
BEGIN 
	Print 'Not Exists!' 
END 
GO 


CREATE PROCEDURE dbo.Integration_Sales_Delete
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
CREATE DATABASE UrbanRetailCo;
GO

USE UrbanRetailCo;
GO

-- Create staging table for bulk import
CREATE TABLE TempInventory (
    TransactionDate VARCHAR(10),
    StoreID VARCHAR(10),
    ProductID VARCHAR(10),
    Category VARCHAR(50),
    Region VARCHAR(50),
    InventoryLevel INT,
    UnitsSold INT,
    UnitsOrdered INT,
    DemandForecast DECIMAL(10,2),
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    WeatherCondition VARCHAR(50),
    [Holiday/Promotion] BIT,
    CompetitorPricing DECIMAL(10,2),
    Seasonality VARCHAR(50)
);

-- Bulk import data from CSV (skip header row)
BULK INSERT TempInventory
FROM 'C:\Users\DELL\OneDrive\Desktop\IIT Guwahati\Solving Inventory Inefficiencies\inventory_forecasting1.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Preview imported data
SELECT TOP 5 * FROM TempInventory;

-- Check date conversion
SELECT TransactionDate, TRY_CONVERT(DATE, TransactionDate, 103) AS ConvertedDate
FROM TempInventory;

-- Create cleaned table with proper data types
SELECT
    TRY_CONVERT(DATE, TransactionDate, 103) AS TransactionDate,
    StoreID, ProductID, Category, Region, InventoryLevel,
    UnitsSold, UnitsOrdered, DemandForecast, Price, Discount,
    WeatherCondition, [Holiday/Promotion], CompetitorPricing, Seasonality
INTO newinventorytable
FROM TempInventory;

-- Check for NULL values in all columns
SELECT 
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN StoreID IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN InventoryLevel IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN UnitsSold IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN UnitsOrdered IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN DemandForecast IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN WeatherCondition IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN [Holiday/Promotion] IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN CompetitorPricing IS NULL THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Seasonality IS NULL THEN 1 ELSE 0 END) AS TotalNullValues
FROM newinventorytable;

-- Check for negative values in numeric fields
SELECT * 
FROM newinventorytable
WHERE 
    InventoryLevel < 0 OR 
    UnitsSold < 0 OR 
    UnitsOrdered < 0 OR 
    DemandForecast < 0 OR 
    Price < 0 OR 
    Discount < 0;
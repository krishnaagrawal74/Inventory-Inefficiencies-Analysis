
USE UrbanRetailCo;
GO

-- Create Stores table (formerly dim_location)
CREATE TABLE Stores (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    StoreID VARCHAR(10),
    Region VARCHAR(50)
);

-- Populate Stores
INSERT INTO Stores (StoreID, Region)
SELECT DISTINCT StoreID, Region
FROM newinventorytable;

-- Verify Stores data
SELECT * FROM Stores;

-- Create Products table (formerly dim_product)
CREATE TABLE Products (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID VARCHAR(10),
    Category VARCHAR(50)
);

-- Populate Products
INSERT INTO Products (ProductID, Category)
SELECT DISTINCT ProductID, Category
FROM newinventorytable;

-- Verify Products data
SELECT * FROM Products;

-- Create Dates table (formerly dim_date)
CREATE TABLE Dates (
    DateKey INT IDENTITY(1,1) PRIMARY KEY,
    TransactionDate DATE,
    Seasonality VARCHAR(50),
    WeatherCondition VARCHAR(50),
    HolidayPromotion BIT
);

-- Populate Dates
INSERT INTO Dates (TransactionDate, Seasonality, WeatherCondition, HolidayPromotion)
SELECT DISTINCT TransactionDate, Seasonality, WeatherCondition, [Holiday/Promotion]
FROM newinventorytable;

-- Verify Dates data
SELECT * FROM Dates;

-- Create InventoryTransactions table (formerly fact_inventory)
CREATE TABLE InventoryTransactions (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT FOREIGN KEY REFERENCES Dates(DateKey),
    ProductKey INT FOREIGN KEY REFERENCES Products(ProductKey),
    LocationKey INT FOREIGN KEY REFERENCES Stores(LocationKey),
    InventoryLevel INT,
    UnitsSold INT,
    UnitsOrdered INT,
    DemandForecast DECIMAL(10,2),
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    CompetitorPricing DECIMAL(10,2)
);

-- Populate InventoryTransactions
INSERT INTO InventoryTransactions (
    DateKey, ProductKey, LocationKey,
    InventoryLevel, UnitsSold, UnitsOrdered,
    DemandForecast, Price, Discount, CompetitorPricing
)
SELECT 
    d.DateKey,
    p.ProductKey,
    l.LocationKey,
    n.InventoryLevel,
    n.UnitsSold,
    n.UnitsOrdered,
    n.DemandForecast,
    n.Price,
    n.Discount,
    n.CompetitorPricing
FROM newinventorytable n
JOIN Dates d ON 
    n.TransactionDate = d.TransactionDate AND
    n.Seasonality = d.Seasonality AND
    n.WeatherCondition = d.WeatherCondition AND
    n.[Holiday/Promotion] = d.HolidayPromotion
JOIN Products p ON 
    n.ProductID = p.ProductID AND
    n.Category = p.Category
JOIN Stores l ON 
    n.StoreID = l.StoreID AND
    n.Region = l.Region;

-- Verify InventoryTransactions data
SELECT * FROM InventoryTransactions;
USE UrbanRetailCo;
GO

-- INSIGHT 1: Low Inventory vs Demand Forecast
-- Identify products whose inventory is significantly lower than their forecasted demand — potential stockout risk.
SELECT 
    p.ProductID,
    l.StoreID,
    l.Region,
    d.TransactionDate,
    f.InventoryLevel,
    f.DemandForecast,
	ROUND(CAST(f.InventoryLevel AS FLOAT) / NULLIF(f.DemandForecast, 0), 3) AS InventoryToDemandRatio
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
JOIN Stores l ON f.LocationKey = l.LocationKey
JOIN Dates d ON f.DateKey = d.DateKey
WHERE 
    f.DemandForecast > 0 AND
    f.InventoryLevel < 0.6 * f.DemandForecast
ORDER BY InventoryToDemandRatio ASC;

-- INSIGHT 2: Inventory Turnover Ratio
-- How efficiently inventory is being sold. High ratio = fast-selling. Low = overstock.
SELECT 
    p.ProductID,
    p.Category,
    ROUND(SUM(f.UnitsSold) * 1.0 / NULLIF(AVG(f.InventoryLevel), 0), 3) AS TurnoverRatio
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductID, p.Category
ORDER BY TurnoverRatio DESC;

-- INSIGHT 3: Weather Effect on Sales
-- Detect which weather patterns drive higher or lower sales.
SELECT 
    d.WeatherCondition,
    p.Category,
    AVG(f.UnitsSold) AS AvgUnitsSold
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
JOIN Dates d ON f.DateKey = d.DateKey
GROUP BY d.WeatherCondition, p.Category
ORDER BY d.WeatherCondition, AvgUnitsSold DESC;

-- INSIGHT 4: Promotion/Holiday Impact on Sales
-- Compare average sales on promotion days vs normal days.
SELECT 
    d.HolidayPromotion,
    p.Category,
    AVG(f.UnitsSold) AS AvgUnitsSold
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
JOIN Dates d ON f.DateKey = d.DateKey
GROUP BY d.HolidayPromotion, p.Category
ORDER BY d.HolidayPromotion DESC, AvgUnitsSold DESC;

-- INSIGHT 5: Reorder Point Suggestion (Assumed Lead Time = 2 days)
-- Estimate a reorder point assuming 2-day delivery delay.
SELECT 
    p.ProductID,
    p.Category,
    ROUND(AVG(f.UnitsSold) * 2, 0) AS ReorderPointEstimate
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductID, p.Category
ORDER BY ReorderPointEstimate DESC;

-- INSIGHT 6: Restocking Lag Detection
-- Detect days where inventory is low and no order placed — suggesting warehouse delays.
SELECT 
    d.TransactionDate,
    p.ProductID,
    l.StoreID,
    f.InventoryLevel,
    f.UnitsSold,
    f.UnitsOrdered
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
JOIN Stores l ON f.LocationKey = l.LocationKey
JOIN Dates d ON f.DateKey = d.DateKey
WHERE 
    f.InventoryLevel < f.UnitsSold AND 
    f.UnitsOrdered = 0
ORDER BY d.TransactionDate;

-- INSIGHT 7: Stock Health Tagging
-- Classify stock as Critical / Low / Safe based on inventory vs forecast.
SELECT 
    d.TransactionDate,
    p.ProductID,
    l.StoreID,
    f.InventoryLevel,
    f.DemandForecast,
    CASE 
        WHEN f.DemandForecast = 0 THEN 'No Forecast'
        WHEN f.InventoryLevel < 0.4 * f.DemandForecast THEN 'Critical'
        WHEN f.InventoryLevel < 0.7 * f.DemandForecast THEN 'Low'
        ELSE 'Safe'
    END AS StockStatus
FROM InventoryTransactions f
JOIN Products p ON f.ProductKey = p.ProductKey
JOIN Stores l ON f.LocationKey = l.LocationKey
JOIN Dates d ON f.DateKey = d.DateKey;
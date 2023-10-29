Select *
From Superstore

--Convert Order Date and Ship Date, Drop original columns

Select CONVERT(date,[Order Date]) as OrderDateConverted, [Order Date]
From Superstore

ALTER TABLE SuperStore
ADD OrderDateConverted DATE

UPDATE SuperStore
SET OrderDateConverted = CONVERT(DATE, [Order Date])

Select CONVERT(date,[Ship Date]) as ShipDateConverted, [Ship Date]
From Superstore

ALTER TABLE SuperStore
ADD ShipDateConverted DATE

UPDATE SuperStore
SET ShipDateConverted = CONVERT(DATE, [Ship Date])

ALTER TABLE Superstore
DROP Column [Order Date], [Ship Date]


--Add a COGS column

Select *
From Superstore
Order By [Row ID]


Select Sales-Profit as COGS, Sales, Profit
From Superstore

ALTER TABLE Superstore
ADD COGS NUMERIC(10, 2)

UPDATE SuperStore
SET COGS = Sales-Profit

-- Add OrderWeek, OrderMonth, OrderYear


Select *
From Superstore
Order By OrderDateConverted

SELECT 
    OrderDateConverted,
    DATEPART(WEEK, OrderDateConverted) AS OrderWeek
FROM Superstore
Order By OrderdateConverted, OrderWeek


SELECT 
    OrderDateConverted,
    Month(OrderDateConverted) AS OrderMonth
FROM Superstore
Order by Orderdateconverted, OrderMonth

SELECT 
    OrderDateConverted,
    YEAR(OrderDateConverted) AS OrderYear
FROM Superstore
Order by Orderdateconverted, OrderYear


ALTER TABLE Superstore
ADD OrderWeek TINYINT, OrderMonth TINYINT, OrderYear INT


UPDATE Superstore
SET OrderWeek = DATEPART(WEEK, OrderDateConverted),
OrderMonth = Month(OrderDateConverted),
OrderYear = Year(OrderDateConverted)

-- Day of the week each OrderDateConverted

SELECT OrderDateConverted, DATENAME(WEEKDAY, OrderDateConverted) AS DayOfWeek
From Superstore
Order by OrderDateConverted

-- Orders per year
SELECT OrderYear, COUNT(OrderDateConverted) as OrdersPerYear
From Superstore
GROUP BY OrderYear
Order By OrderYear


-- Orders Per Region

SELECT Region, COUNT(OrderDateConverted) as OrdersPerRegion
From Superstore
Group by Region


--Total count of transactions for each segment and percentages

SELECT Segment, COUNT(OrderDateConverted) as OrdersPerSegment, FORMAT((COUNT(OrderDateConverted) * 100.0 / 
SUM(COUNT(OrderDateConverted)) OVER ()), '0.00') as Percentage
FROM Superstore  
GROUP BY Segment;


SELECT *
FROM Superstore  
Order BY OrderDateConverted;

--Orders by category total and percentage 
SELECT Category,  COUNT(OrderDateConverted) as OrdersPerCategory, FORMAT((COUNT(OrderDateConverted) * 100.0 / 
SUM(COUNT(OrderDateConverted)) OVER ()), '0.00') as Percentage
FROM Superstore  
Group BY Category;

-- Month over Month analysis Revenue, EXPs 

SELECT *
FROM Superstore  
Order BY OrderDateConverted;


WITH MonthlyData AS (
    SELECT
        DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(COGS) AS TotalCOGS
    FROM Superstore
    GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0)
)
SELECT
    m1.Month AS CurrentMonth,
    ROUND(m1.TotalSales,2) AS CurrentMonthSales,
    ROUND(m1.TotalCOGS,2) AS CurrentMonthCOGS,
    m2.Month AS PreviousMonth,
    ROUND(m2.TotalSales,2) AS PreviousMonthSales,
    ROUND(m2.TotalCOGS,2) AS PreviousMonthCOGS,
    ROUND(m1.TotalSales - m2.TotalSales, 2) AS SalesMoMChange,
    ROUND(m1.TotalCOGS - m2.TotalCOGS, 2) AS COGSMoMChange
FROM MonthlyData m1
LEFT JOIN MonthlyData m2 ON m1.Month = DATEADD(MONTH, 1, m2.Month)
ORDER BY m1.Month;




--Using CTE Orders total sales 4 weeks before and 4 weeks after + Sales change $ amount and % change

WITH SalesBefore AS (
    SELECT
        SUM(Sales) AS TotalSalesBefore
    FROM Superstore
    WHERE OrderDateConverted >= DATEADD(WEEK, -4, '2017-06-15')
      AND OrderDateConverted < '2017-06-15'
),
SalesAfter AS (
    SELECT
        SUM(Sales) AS TotalSalesAfter
    FROM Superstore
    WHERE OrderDateConverted > '2017-06-15'
      AND OrderDateConverted <= DATEADD(WEEK, 4, '2017-06-15')
)
SELECT
    '4 Weeks Before' AS Period,
    ROUND(TotalSalesBefore,2) AS TotalSales,
    NULL AS SalesChange,
    NULL AS SalesChangePercentage
FROM SalesBefore

UNION ALL

SELECT
    '4 Weeks After' AS Period,
    ROUND(TotalSalesAfter,2) AS TotalSales,
    ROUND(TotalSalesAfter - TotalSalesBefore,2) AS SalesChange,
   ROUND((TotalSalesAfter - TotalSalesBefore) * 100.0 / TotalSalesBefore,2) AS SalesChangePercentage
FROM SalesBefore, SalesAfter;


-- Create Views Category, SubCategory, MoMSales/COGS Change, 

Create View OrdersPerCategory as
SELECT Category,  COUNT(OrderDateConverted) as OrdersPerCategory, FORMAT((COUNT(OrderDateConverted) * 100.0 / 
SUM(COUNT(OrderDateConverted)) OVER ()), '0.00') as Percentage
FROM Superstore  
Group BY Category;


CREATE VIEW OrdersPerSubCategory AS
SELECT Category, [Sub-Category], COUNT(OrderDateConverted) AS OrdersPerSubCategory,
(COUNT(OrderDateConverted) * 100.0) / SUM(COUNT(OrderDateConverted)) OVER () AS Percentage
FROM Superstore
GROUP BY Category, [Sub-Category]

Select * from OrdersPerSubCategory
Order By Category, [Sub-Category]


CREATE VIEW MonthlySalesAndCOGSAnalysis AS
WITH MonthlyData AS (
    SELECT
        DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(COGS) AS TotalCOGS
    FROM Superstore
    GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0)
)
SELECT
    m1.Month AS CurrentMonth,
    ROUND(m1.TotalSales, 2) AS CurrentMonthSales,
    ROUND(m1.TotalCOGS, 2) AS CurrentMonthCOGS,
    m2.Month AS PreviousMonth,
    ROUND(m2.TotalSales, 2) AS PreviousMonthSales,
    ROUND(m2.TotalCOGS, 2) AS PreviousMonthCOGS,
    ROUND(m1.TotalSales - m2.TotalSales, 2) AS SalesMoMChange,
    ROUND(m1.TotalCOGS - m2.TotalCOGS, 2) AS COGSMoMChange
FROM MonthlyData m1
LEFT JOIN MonthlyData m2 ON m1.Month = DATEADD(MONTH, 1, m2.Month);

Select * from MonthlySalesAndCOGSAnalysis
Order BY CurrentMonth

ALTER VIEW MonthlySalesAndCOGSAnalysis AS
WITH MonthlyData AS (
    SELECT
        DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(COGS) AS TotalCOGS
    FROM Superstore
    GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0)
)
SELECT
    m1.Month AS CurrentMonth,
    ROUND(m1.TotalSales, 2) AS CurrentMonthSales,
    ROUND(m1.TotalCOGS, 2) AS CurrentMonthCOGS,
    m2.Month AS PreviousMonth,
    ROUND(m2.TotalSales, 2) AS PreviousMonthSales,
    ROUND(m2.TotalCOGS, 2) AS PreviousMonthCOGS,
    ROUND(((m1.TotalSales - m2.TotalSales) / m2.TotalSales) * 100, 2) AS SalesMoMChangePercent,
    ROUND(((m1.TotalCOGS - m2.TotalCOGS) / m2.TotalCOGS) * 100, 2) AS COGSMoMChangePercent
FROM MonthlyData m1
LEFT JOIN MonthlyData m2 ON m1.Month = DATEADD(MONTH, 1, m2.Month);

CREATE View ProfitPerState AS 
Select State, ROUND(SUM(Sales),2) as SalesPerState, ROUND(SUM(COGS),2) as COGSPerState, ROUND(SUM(PROFIT),2) As ProfitPerState
From Superstore
GROUP BY State


-- Create temp table using CTE
WITH MonthlyData AS (
    SELECT
        DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(COGS) AS TotalCOGS
    FROM Superstore
    GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDateConverted), 0)
)
SELECT *
INTO #TempMonthlyData
FROM MonthlyData;

-- Now you can reference this temp monthly table
SELECT * FROM #TempMonthlyData;





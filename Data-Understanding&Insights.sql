USE PortfolioProject2Housedata

-- Total number of sales
SELECT COUNT(*) AS TotalSales FROM HousingData

-- Most common land use type
SELECT LandUse, COUNT(*) AS Frequency FROM HousingData
GROUP BY LandUse ORDER BY Frequency DESC

-- Average price per land use type
SELECT LandUse, AVG(SalePrice) AS AvgPrice FROM HousingData
GROUP BY LandUse ORDER BY AvgPrice DESC

-- Top 10 most expensive properties sold
SELECT TOP 10 * FROM HousingData
ORDER BY SalePrice DESC

-- Price per Acre for each record
SELECT ParcelID, SalePrice, Acreage, (SalePrice / NULLIF(Acreage, 0)) AS PricePerAcre
FROM HousingData WHERE Acreage IS NOT NULL

-- Average number of bedrooms per land use
SELECT LandUse, AVG(Bedrooms) AS AvgBedrooms FROM HousingData
GROUP BY LandUse

-- Average building value per bedroom count
SELECT Bedrooms, AVG(BuildingValue) AS AvgBuildingValue
FROM HousingData WHERE Bedrooms IS NOT NULL
GROUP BY Bedrooms


-- Properties where SalePrice < TotalValue (potential undervalued)
SELECT * FROM HousingData
WHERE SalePrice < TotalValue * 0.8

-- Rank properties within each year by sale price
SELECT *, RANK() OVER (PARTITION BY SaleYear ORDER BY SalePrice DESC) AS PriceRank
FROM HousingData

-- Compare each sale to the previous sale by date
SELECT ParcelID, SaleDate, SalePrice,
       LAG(SalePrice) OVER (PARTITION BY ParcelID ORDER BY SaleDate) AS PrevSalePrice
FROM HousingData

-- Count properties built before 1950
SELECT COUNT(*) AS Pre1950Homes FROM HousingData
WHERE YearBuilt < 1950

-- Avg. sale price by number of full baths
SELECT FullBath, AVG(SalePrice) AS AvgPrice
FROM HousingData
GROUP BY FullBath

-- Identify most frequent owners
SELECT OwnerName, COUNT(*) AS NumProperties
FROM HousingData
GROUP BY OwnerName ORDER BY NumProperties DESC

-- CTE to calculate % difference between TotalValue and SalePrice
WITH ValueDiff AS (
    SELECT *,
        (SalePrice - TotalValue) * 1.0 / TotalValue AS RelativeDifference
    FROM HousingData
    WHERE TotalValue > 0
)
SELECT * FROM ValueDiff WHERE RelativeDifference < -0.2

-- Distribution of Acreage
SELECT 
    CASE 
        WHEN Acreage < 1 THEN '< 1 acre'
        WHEN Acreage BETWEEN 1 AND 5 THEN '1-5 acres'
        WHEN Acreage BETWEEN 5 AND 20 THEN '5-20 acres'
        ELSE '> 20 acres'
    END AS AcreageCategory,
    COUNT(*) AS Count
FROM HousingData
WHERE Acreage IS NOT NULL
GROUP BY 
    CASE 
        WHEN Acreage < 1 THEN '< 1 acre'
        WHEN Acreage BETWEEN 1 AND 5 THEN '1-5 acres'
        WHEN Acreage BETWEEN 5 AND 20 THEN '5-20 acres'
        ELSE '> 20 acres'
    END

-- Avg. SalePrice vs BuildingValue correlation
SELECT CORR(SalePrice * 1.0, BuildingValue * 1.0) AS PriceBuildingCorr
FROM HousingData WHERE SalePrice IS NOT NULL AND BuildingValue IS NOT NULL

-- Avg. SalePrice by TaxDistrict
SELECT TaxDistrict, AVG(SalePrice) AS AvgPrice FROM HousingData
GROUP BY TaxDistrict

-- Top 5 most frequent ParcelIDs (possibly multiple transactions)
SELECT ParcelID, COUNT(*) AS SalesCount
FROM HousingData
GROUP BY ParcelID
ORDER BY SalesCount DESC

-- Number of properties with missing bedrooms or year built
SELECT 
    SUM(CASE WHEN Bedrooms IS NULL THEN 1 ELSE 0 END) AS MissingBedrooms,
    SUM(CASE WHEN YearBuilt IS NULL THEN 1 ELSE 0 END) AS MissingYearBuilt
FROM HousingData

-- List of parcels with highest appreciation (SalePrice vs TotalValue)
SELECT TOP 10 *, (SalePrice - TotalValue) AS Appreciation
FROM HousingData
WHERE TotalValue > 0
ORDER BY Appreciation DESC

-- Avg. sale price for properties with more than 4 bedrooms
SELECT AVG(SalePrice) AS AvgHighBedroomPrice
FROM HousingData WHERE Bedrooms > 4

-- Monthly sales trend
SELECT DATEPART(MONTH, SaleDate) AS SaleMonth, COUNT(*) AS MonthlySales
FROM HousingData GROUP BY DATEPART(MONTH, SaleDate)

-- Property types with only 1 sale
SELECT LandUse, COUNT(*) AS Count FROM HousingData
GROUP BY LandUse HAVING COUNT(*) = 1

-- Sale price per square foot approximation if acreage is small
SELECT *, (SalePrice / (Acreage * 43560.0)) AS PricePerSqFt
FROM HousingData WHERE Acreage IS NOT NULL AND Acreage < 1

-- Percentage of vacant properties
SELECT 
    (SUM(CASE WHEN SoldAsVacant = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS VacantPercentage
FROM HousingData

-- Identify properties with 0 value in Land or Building
SELECT * FROM HousingData WHERE LandValue = 0 OR BuildingValue = 0

-- Median sale price per year using PERCENTILE_CONT
SELECT DISTINCT
    SaleYear,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SalePrice) OVER (PARTITION BY SaleYear) AS MedianSalePrice
FROM HousingData

-- Year-over-Year growth in average SalePrice
WITH AvgPricePerYear AS (
    SELECT SaleYear, AVG(SalePrice) AS AvgPrice
    FROM HousingData
    GROUP BY SaleYear
)
SELECT 
    SaleYear,
    AvgPrice,
    LAG(AvgPrice) OVER (ORDER BY SaleYear) AS PrevYearAvg,
    ROUND((AvgPrice - LAG(AvgPrice) OVER (ORDER BY SaleYear)) * 100.0 / NULLIF(LAG(AvgPrice) OVER (ORDER BY SaleYear), 0), 2) AS YoYChangePercent
FROM AvgPricePerYear

-- Most common ZIP code (assuming ZIP is last 5 chars in OwnerAddress)
SELECT 
    RIGHT(OwnerAddress, 5) AS ZipCode,
    COUNT(*) AS Count
FROM HousingData
WHERE ISNUMERIC(RIGHT(OwnerAddress, 5)) = 1
GROUP BY RIGHT(OwnerAddress, 5)
ORDER BY Count DESC

-- Detect undervalued properties (SalePrice < 60% of TotalValue)
SELECT * FROM HousingData
WHERE TotalValue > 0 AND SalePrice < TotalValue * 0.6

-- Detect potential flip: same ParcelID sold multiple times in short time
WITH Resales AS (
    SELECT ParcelID, SaleDate,
           LEAD(SaleDate) OVER (PARTITION BY ParcelID ORDER BY SaleDate) AS NextSaleDate,
           DATEDIFF(DAY, SaleDate, LEAD(SaleDate) OVER (PARTITION BY ParcelID ORDER BY SaleDate)) AS DaysBetweenSales
    FROM HousingData
)
SELECT * FROM Resales WHERE DaysBetweenSales IS NOT NULL AND DaysBetweenSales < 180

-- Monthly rolling average sale price per year
WITH MonthlyAverages AS (
    SELECT
        YEAR(SaleDate) AS Year,
        MONTH(SaleDate) AS Month,
        AVG(SalePrice) AS AvgMonthlyPrice
    FROM HousingData
    GROUP BY YEAR(SaleDate), MONTH(SaleDate)
)
SELECT *,
    AVG(AvgMonthlyPrice) OVER (PARTITION BY Year ORDER BY Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Rolling3MonthAvg
FROM MonthlyAverages

-- Count properties with same address sold more than once
SELECT PropertySplitAddress, COUNT(*) AS TimesSold
FROM HousingData
GROUP BY PropertySplitAddress
HAVING COUNT(*) > 1

-- Most frequent owner per ZIP code (from OwnerAddress ZIP)
WITH OwnerZips AS (
    SELECT OwnerName, RIGHT(OwnerSplitAddress, 5) AS Zip
    FROM HousingData
    WHERE ISNUMERIC(RIGHT(OwnerSplitAddress, 5)) = 1
)
SELECT Zip, OwnerName, COUNT(*) AS PropertyCount
FROM OwnerZips
GROUP BY Zip, OwnerName
HAVING COUNT(*) = (
    SELECT MAX(Cnt) FROM (
        SELECT OwnerName, COUNT(*) AS Cnt
        FROM OwnerZips z2
        WHERE z2.Zip = OwnerZips.Zip
        GROUP BY OwnerName
    ) AS InnerCounts
)

-- Sale price per bedroom, grouped by LandUse
SELECT LandUse, Bedrooms, AVG(SalePrice) AS AvgPrice
FROM HousingData
WHERE Bedrooms IS NOT NULL
GROUP BY LandUse, Bedrooms
ORDER BY LandUse, Bedrooms

-- Properties with identical TotalValue but different SalePrice
SELECT ParcelID, TotalValue, COUNT(DISTINCT SalePrice) AS PriceVariety
FROM HousingData
GROUP BY ParcelID, TotalValue
HAVING COUNT(DISTINCT SalePrice) > 1

-- Owner with largest total property value
SELECT OwnerName, SUM(TotalValue) AS TotalOwnedValue
FROM HousingData
GROUP BY OwnerName
ORDER BY TotalOwnedValue DESC

-- Count of properties where LandValue is significantly higher than BuildingValue
SELECT COUNT(*) AS LandHeavyProperties
FROM HousingData
WHERE LandValue > BuildingValue * 3



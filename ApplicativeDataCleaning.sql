use PortfolioProject2Housedata

-- Understanding the Dataset and its contents.
Select * From HousingData
Select Top 10 * From HousingData

-- The sale date looks a lot off, hence I shall standardize the date format.
Select SaleDate, CONVERT ( Date, SaleDate) as UpdatedDate From HousingData
Update HousingData
SET SaleDate= CONVERT(DATE, SaleDate)

-- Another way if the UPDATE method doesnt work directly is by adding a updated colum and dropping the original one.
ALTER TABLE HousingData 
ADD
SaleDateUpdated Date; 
UPDATE HousingData
SET SaleDateUpdated = CONVERT(DATE, SaleDate)

EXEC sp_rename 'HousingData.SaleDateUpdated', 'SaleDate', 'COLUMN';

-- Populate Property Address Data

-- Understanding where is the null value occuring and what can we derive. 
Select [UniqueID ],ParcelID, PropertySplitAddress From HousingData
Where PropertySplitAddress is null
-- Understanding all the factors
Select * From HousingData
Where PropertySplitAddress is null

-- It is observed that ParcelID plays a key role, similar parcel IDs with similar 
-- property address have conditions where the property address for a seperate order is not mentioned.

select A.ParcelID, A.PropertySplitAddress, B.ParcelID, B.PropertySplitAddress 
from HousingData A
join HousingData B
	on A.ParcelID=B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertySplitAddress is not null

Update A
SET PropertySplitAddress = ISNULL(A.PropertySplitAddress, B.PropertySplitAddress)
from HousingData A
join HousingData B
	on A.ParcelID=B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertySplitAddress is null

Select * from HousingData where PropertySplitAddress is null

-- Now all the null values in PropertySplitAddress Have been resolved.

-- Breaking out address into Individual columns.
Select PropertySplitAddress From HousingData

Select 
SUBSTRING (PropertySplitAddress, 1, CHARINDEX(',', PropertySplitAddress)-1) As Address
,SUBSTRING (PropertySplitAddress, CHARINDEX(',', PropertySplitAddress)+1, LEN(PropertySplitAddress)) as Address
from HousingData

-- Adding the Address as a seperate column.
ALTER TABLE HousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress= SUBSTRING (PropertySplitAddress, 1, CHARINDEX(',', PropertySplitAddress)-1)

Select PropertySplitAddress from HousingData

-- Adding the City as a seperate column.
ALTER TABLE HousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE HousingData
SET PropertySplitCity= SUBSTRING (PropertySplitAddress, CHARINDEX(',', PropertySplitAddress)+1, LEN(PropertySplitAddress))

Select PropertySplitCity from HousingData

-- Removing Property Address as the together column
ALTER TABLE HousingData
Drop Column PropertySplitAddress

Select * from HousingData

-- If observed closely, it will be noticed that the Owner Address is combined of Address, City and state names as well.
-- This makes it uneccesarily complicated for querying off later, as well as in visualizations.
Select OwnerAddress From HousingData

-- Applying PARSENAME and splitting the OwnerAddress into its respective split sections.
SELECT PARSENAME(Replace(OwnerAddress,',','.'),3) as OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),2) as OwnerCity,
PARSENAME(Replace(OwnerAddress,',','.'),1) as OwnerState
from HousingData

-- Add these columns seperately in the table.

-- Adding OwnerAddress
ALTER TABLE HousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HousingData
SET OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)

Select OwnerSplitAddress from HousingData 

-- Adding the city
ALTER TABLE HousingData
ADD OwnerCity Nvarchar(255);

UPDATE HousingData
SET OwnerCity= PARSENAME(Replace(OwnerAddress,',','.'),2)

Select OwnerCity from HousingData

-- Adding the state
ALTER TABLE HousingData
ADD OwnerState Nvarchar(255);

UPDATE HousingData
SET OwnerState= PARSENAME(Replace(OwnerAddress,',','.'),1)

Select OwnerState from HousingData 

-- Drop the original column as it is not needed anymore.
ALTER TABLE HousingData
DROP COLUMN  OwnerAddress

Select * from HousingData

-- Chnage Y and N to Yes and No in 'Sold as Vacant' field
Select DISTINCT(SoldAsVacant) from HousingData

--It can be visibly seen that there are four fields, additional ones being Y and N that represent the same thing.
Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) as Number
from HousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE
	When SoldAsVacant= 'Y' then 'Yes'
	When SoldAsVacant= 'N' then 'No'
	ELSE SoldAsVacant
	END
from HousingData

-- Finally updating the main dataset.
UPDATE HousingData
SET SoldAsVacant= 	CASE
	When SoldAsVacant= 'Y' then 'Yes'
	When SoldAsVacant= 'N' then 'No'
	ELSE SoldAsVacant
	END
from HousingData

-- Remove Duplicaftes
-- Here we will try to remove the duplicates that are present in out dataset
-- Using PartitionBY and CTEs, we Seperated the duplicate rows from the entire dataset.
-- The calculation here shows 104 rows which are duplicate.
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				PropertySplitAddress,
				PropertySplitCity,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From HousingData)
Select * from RowNumCTE
where row_num>1
Order BY PropertySplitAddress

-- Deleteing the duplicate values
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				PropertySplitAddress,
				PropertySplitCity,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From HousingData)
Delete from RowNumCTE
where row_num>1

--(104 rows affected)


-- Remove duplicate records based on all columns
WITH CTE_Duplicates AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY UniqueID, ParcelID, PropertyAddress, SaleDate, SalePrice ORDER BY UniqueID) AS rn
    FROM HousingData
)
DELETE FROM CTE_Duplicates WHERE rn > 1

-- Standardize 'SoldAsVacant' entries to Yes/No
UPDATE HousingData
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant IN ('Y', 'Yes', 'YES') THEN 'Yes'
        WHEN SoldAsVacant IN ('N', 'No', 'NO') THEN 'No'
        ELSE SoldAsVacant
    END

-- Remove leading/trailing whitespaces in PropertyAddress
UPDATE HousingData
SET PropertyAddress = LTRIM(RTRIM(PropertyAddress))

-- Title case OwnerName
UPDATE HousingData
SET OwnerName = CONCAT(UPPER(LEFT(OwnerName, 1)), LOWER(SUBSTRING(OwnerName, 2, LEN(OwnerName)-1)))
WHERE OwnerName IS NOT NULL

-- Replace NULL in SoldAsVacant with 'Unknown'
UPDATE HousingData
SET SoldAsVacant = 'Unknown'
WHERE SoldAsVacant IS NULL

-- Replace NULL TaxDistrict with most frequent value
UPDATE HousingData
SET TaxDistrict = (
    SELECT TOP 1 TaxDistrict FROM HousingData
    WHERE TaxDistrict IS NOT NULL
    GROUP BY TaxDistrict ORDER BY COUNT(*) DESC
)
WHERE TaxDistrict IS NULL

-- Ensure TotalValue = LandValue + BuildingValue
UPDATE HousingData
SET TotalValue = LandValue + BuildingValue
WHERE LandValue IS NOT NULL AND BuildingValue IS NOT NULL

-- Replace 0s in YearBuilt with NULLs (possible missing data)
UPDATE HousingData
SET YearBuilt = NULL
WHERE YearBuilt = 0

-- Flag properties with unusually high Acreage (> 100 acres)
ALTER TABLE HousingData ADD AcreageOutlierFlag BIT
UPDATE HousingData
SET AcreageOutlierFlag = CASE WHEN Acreage > 100 THEN 1 ELSE 0 END

-- Remove non-alphanumeric characters in LegalReference
UPDATE HousingData
SET LegalReference = REPLACE(REPLACE(REPLACE(LegalReference, '-', ''), '/', ''), '.', '')

-- Standardize FullBath and HalfBath to 0 where NULL
UPDATE HousingData
SET FullBath = 0 WHERE FullBath IS NULL

UPDATE HousingData
SET HalfBath = 0 WHERE HalfBath IS NULL

-- Fill missing Bedrooms using modal value
UPDATE HousingData
SET Bedrooms = (
    SELECT TOP 1 Bedrooms FROM HousingData
    WHERE Bedrooms IS NOT NULL
    GROUP BY Bedrooms ORDER BY COUNT(*) DESC
)
WHERE Bedrooms IS NULL

-- Fill missing BuildingValue with LandValue*2 (assumption)
UPDATE HousingData
SET BuildingValue = LandValue * 2
WHERE BuildingValue IS NULL AND LandValue IS NOT NULL

-- Remove future dates in SaleDate
DELETE FROM HousingData
WHERE SaleDate > GETDATE()

-- Convert PropertySplitAddress to consistent casing
UPDATE HousingData
SET PropertySplitAddress = UPPER(PropertySplitAddress)

-- Add column to extract year of sale
ALTER TABLE HousingData ADD SaleYear INT
UPDATE HousingData
SET SaleYear = YEAR(SaleDate)

-- Set OwnerName to 'Unknown' if NULL
UPDATE HousingData
SET OwnerName = 'Unknown'
WHERE OwnerName IS NULL

-- Trim and standardize TaxDistrict values
UPDATE HousingData
SET TaxDistrict = UPPER(LTRIM(RTRIM(TaxDistrict)))
-- Data cleaning in SQL Using Nashville Housing DataSet 2013_2016


Select *
From `Portfolio Project`.nashville_housing_data_2013_2016;
------------------------------------------------------------------------------------
-- Standardize date format

Select Sale Date 
From `Portfolio Project`.nashville_housing_data_2013_2016;

ALTER TABLE nashville_housing_data_2013_2016
Add SaleDateConverted Date;

Update nashville_housing_data_2013_2016
SET SaleDateConverted = CONVERT(Date , Sale Date)
--------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From `Portfolio Project`.nashville_housing_data_2013_2016
-- Where Property Address is null
order by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From `Portfolio Project`.nashville_housing_data_2013_2016 
JOIN `Portfolio Project`.nashville_housing_data_2013_2016 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.Property Address is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From `Portfolio Project`.nashville_housing_data_2013_2016
JOIN`Portfolio Project`.nashville_housing_data_2013_2016
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Seperate Address into Individual Columns (Address, City, State)


Select PropertyAddress
From `Portfolio Project`.nashville_housing_data_2013_2016
--Where Property Address is null
--order by Parcel ID

SELECT
SUBSTRING(Property Address, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(Property Address, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From `Portfolio Project`.nashville_housing_data_2013_2016

ALTER TABLE `Portfolio Project`.nashville_housing_data_2013_2016
Add PropertySplitAddress Nvarchar(255);

Update `Portfolio Project`.nashville_housing_data_2013_2016
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE `Portfolio Project`.nashville_housing_data_2013_2016
Add PropertySplitCity Nvarchar(255);

Update `Portfolio Project`.nashville_housing_data_2013_2016
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

Select *
From `Portfolio Project`.nashville_housing_data_2013_2016


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From `Portfolio Project`.nashville_housing_data_2013_2016


ALTER TABLE nashville_housing_data_2013_2016
Add OwnerSplitAddress Nvarchar(255);

Update nashville_housing_data_2013_2016
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nashville_housing_data_2013_2016
Add OwnerSplitCity Nvarchar(255);

Update nashville_housing_data_2013_2016
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE nashville_housing_data_2013_2016
Add OwnerSplitState Nvarchar(255);

Update nashville_housing_data_2013_2016
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


Select *
From `Portfolio Project`.nashville_housing_data_2013_2016

--------------------------------------------------------------------------------------------------------------------------

-- Update Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From `Portfolio Project`.nashville_housing_data_2013_2016
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From `Portfolio Project`.nashville_housing_data_2013_2016


Update nashville_housing_data_2013_2016
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From `Portfolio Project`.nashville_housing_data_2013_2016
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

Select *
From `Portfolio Project`.nashville_housing_data_2013_2016;

-------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From `Portfolio Project`.nashville_housing_data_2013_2016;


ALTER TABLE `Portfolio Project`.nashville_housing_data_2013_2016
DROP COLUMN OwnerAddress, Tax District, Property Address, SaleDate

-----------------------------------------------------------------------------------------------


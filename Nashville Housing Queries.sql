Select * 
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaledateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)


ALTER Table NashvilleHousing
ADD SaledateConverted Date;

UPDATE NashvilleHousing
SET SaledateConverted=CONVERT(Date,SaleDate)



-- Populate Property Address Data



Select *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID
, b.PropertyAddress, ISNULL(a.propertyaddress
, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress=ISNULL(a.propertyaddress
, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(Propertyaddress, 1, 
CHARINDEX(',', Propertyaddress)-1 ) as Address
, SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress)+1, 
LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER Table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(Propertyaddress, 1, 
CHARINDEX(',', Propertyaddress)-1 )



ALTER Table NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(Propertyaddress, 
CHARINDEX(',', Propertyaddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(Owneraddress,',','.'),3)
,PARSENAME(REPLACE(Owneraddress,',','.'),2)
,PARSENAME(REPLACE(Owneraddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing



ALTER Table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE
(Owneraddress,',','.'),3)


ALTER Table NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(
Owneraddress,',','.'),2)

ALTER Table NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(
Owneraddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SOLDasvacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2





Select SoldAsVacant,
CASE WHEN SoldAsVacant='y' THEN 'Yes'
WHEN SoldAsVacant ='n' then 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='y' THEN 'Yes'
WHEN SoldAsVacant ='n' then 'No'
ELSE SoldAsVacant
END



-- Remove Duplicates

WITH RowNumCTE as(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, 
LegalReference
ORDER BY UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing

--ORDER BY ParcelID

SELECT *
From RowNumCTE
WHERE row_num>1


--ORDER BY PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

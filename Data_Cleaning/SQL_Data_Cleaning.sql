--/* DATA CLEANING WITH SQL */

SELECT *
FROM NashvilleHousing

--CHANGE Date formats
SELECT saledate, CONVERT (date, saledate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN saledate date

SELECT saledate
FROM NashvilleHousing

-- /* POPULATE PROPERTY ADDRESS DATA */

SELECT * --PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
order by ParcelID

--To set values in the attribute "PropertyAddress" we need to join on the table
--Looking at the data, we can see that there are multiple parcelID with same value
--Same parcel value has the same PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Update the table with the correct PropertyAddress
Update a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Break Address into Individual Columns(Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--order by ParcelID

--We are going to use sub-string and character index search 

--First Seperate from the start untill the comma
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
	--CHARINDEX(',',PropertyAddress)
FROM NashvilleHousing


--Then Seperate after comma till the end of the string
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
	
FROM NashvilleHousing

--Now we create two new columns

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

--/* FORMAT OWNER ADDRESS */

SELECT OwnerAddress
FROM NashvilleHousing
--WHERE OwnerAddress IS NOT NULL

--We are going to use parsename to seperate
--Parsename looks for periods (.) not commas
SELECT
PARSENAME(REPLACE (OwnerAddress, ',','.'),3),
PARSENAME(REPLACE (OwnerAddress, ',','.'),2),
PARSENAME(REPLACE (OwnerAddress, ',','.'),1)
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE (OwnerAddress, ',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE (OwnerAddress, ',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE (OwnerAddress, ',','.'),1)


--/* CHANGE Y and N to Yes and No in "SoldAsVacant" */

--We are going to use Case statements for this

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END


--REMOVE Duplicates
--Use CTE
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num>1

--Delete unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
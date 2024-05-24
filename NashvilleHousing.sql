SELECT *
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`




-- Populate Property Address Data
SELECT *
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing` AS a
JOIN `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing` AS b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing` AS a
JOIN `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing` AS b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress IS NULL




-- Breaking up Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`


SELECT 
  SPLIT(PropertyAddress, ',')[SAFE_OFFSET(0)] AS StreetAddress,
  IF(ARRAY_LENGTH(SPLIT(PropertyAddress, ',')) > 1, SPLIT(PropertyAddress, ',')[SAFE_OFFSET(1)], NULL) AS City
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`


ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ADD COLUMN PropertyStreetAddress STRING;

UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET PropertyStreetAddress = SPLIT(PropertyAddress, ',')[SAFE_OFFSET(0)];

ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ADD COLUMN PropertyCity STRING;

UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET PropertyCity = IF(ARRAY_LENGTH(SPLIT(PropertyAddress, ',')) > 1, SPLIT(PropertyAddress, ',')[SAFE_OFFSET(1)], NULL);




-- Gathering State
SELECT
  SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(0)] AS OwnerStreet,
  SPLIT(SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(1)], ' ')[SAFE_OFFSET(0)] AS OwnerCity,
  SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(2)] AS OwnerState
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`

--Owner Street Split
ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ADD COLUMN OwnerStreet STRING;

UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET OwnerStreet = SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(0)];

--Owner City Split
ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ADD COLUMN OwnerCity STRING;

UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET OwnerCity = SPLIT(SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(1)], ' ')[SAFE_OFFSET(0)];

--Owner State Split
ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ADD COLUMN OwnerState STRING;

UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET OwnerState = SPLIT(OwnerAddress, ', ')[SAFE_OFFSET(2)];





-- Changing Y and N to Yes and No in the column "Sold As Vacant" field
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
GROUP BY SoldAsVacant
ORDER BY 2

SELECT DISTINCT(SoldAsVacant)
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`


UPDATE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END;




-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER()OVER(
    PARTITION BY  ParcelID,
                  PropertyAddress,
                  SalePrice,
                  SaleDate,
                  LegalReference
                  ORDER BY 
                    UniqueID_
  ) AS row_num
FROM `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress





--DELETE UNUSED COLUMNS
ALTER TABLE `my-first-sandbox-project-jsuth.nashville_housing_data.NashvilleHousing`
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


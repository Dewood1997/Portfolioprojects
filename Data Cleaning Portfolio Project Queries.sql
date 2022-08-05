/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

 
Select SaleDateConverted, Convert(Date,SaleDate)
from Portfolio_Project..NashvilleHousing
 

Update NashvilleHousing
SET SaleDate= Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted= Convert(Date,SaleDate)

-- If it doesn't Update properly



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from Portfolio_Project..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
Join Portfolio_Project..NashvilleHousing b
on a.ParcelID =b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]

where a.PropertyAddress is null


Update a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
Join Portfolio_Project..NashvilleHousing b
on a.ParcelID =b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]

where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from Portfolio_Project..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address 
from Portfolio_Project..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio_Project..NashvilleHousing


--ownerAddress split using the parse name(alternative way for the substrings)
--Parsename is only useful with periods; That's why commas should be repalced with periods.
Select OwnerAddress
From Portfolio_Project..NashvilleHousing

--backwards seperating 
Select 
PARSENAME(Replace(OwnerAddress,',','.'),1),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),3)
From Portfolio_Project..NashvilleHousing

--upwards seperating

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From Portfolio_Project..NashvilleHousing

--Adding these columns and values

--OwnerSplitAddress Column 

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)

--OwnerSplitCity Column

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(Replace(OwnerAddress,',','.'),2)

--OwnerSplitState Column

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress,',','.'),1)


Select *
from Portfolio_Project..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT( SoldAsVacant)
from Portfolio_Project..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
  CASE When SoldAsVacant= 'Y' THEN 'Yes'
       When SoldAsVacant= 'N' THEN 'No'
	   Else SoldAsVacant 
	   End 
From Portfolio_Project..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant= CASE When SoldAsVacant= 'Y' THEN 'Yes'
       When SoldAsVacant= 'N' THEN 'No'
	   Else SoldAsVacant 
	   End 



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE As(
select *, 
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				   UniqueID
				   ) row_num

From Portfolio_Project..NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Portfolio_Project..NashvilleHousing

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN SaleDate





























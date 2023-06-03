--data cleaning in sql queries

select * from Portfolio..nashvilleHousing;

--standardize date formate

select SaleDate, convert(Date,SaleDate) from Portfolio..nashvilleHousing


update nashvilleHousing
set SaleDate = convert(date, saledate)

;

alter table nashvilleHousing
add SaleDateConverted Date;

update nashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted from Portfolio..nashvilleHousing


-- Populate Property Address data

select *, PropertyAddress from Portfolio..nashvilleHousing 
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Portfolio..nashvilleHousing a
join Portfolio..nashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Portfolio..nashvilleHousing a
join Portfolio..nashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 


--Breaking out address into individual columns(Address, City, State)

select  PropertyAddress from Portfolio..nashvilleHousing 
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from Portfolio..nashvilleHousing 

alter table nashvilleHousing
add PropertySplitAddress nvarchar(255);

update nashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

alter table nashvilleHousing
add PropertyCity nvarchar(255);

update nashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


select* from Portfolio..nashvilleHousing




select OwnerAddress from Portfolio..nashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',', '.'), 3),
PARSENAME(replace(OwnerAddress,',', '.'), 2),
PARSENAME(replace(OwnerAddress,',', '.'), 1)
from Portfolio..nashvilleHousing

alter table nashvilleHousing
add OwnerSplitAddress nvarchar(255);

update nashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.'), 3)

alter table nashvilleHousing
add OwnerCity nvarchar(255);

update nashvilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress,',', '.'), 2)

alter table nashvilleHousing
add OwnerState nvarchar(255);

update nashvilleHousing
set OwnerState = PARSENAME(replace(OwnerAddress,',', '.'), 1)


select * from Portfolio..nashvilleHousing


-- change Y and N to Yes and No in 'Sold as Vacant' Field


select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio..nashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Portfolio..nashvilleHousing


update nashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


-- Remove Duplicates

select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
						  )row_num
					
from Portfolio..nashvilleHousing
order by ParcelID



with rownumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
						  )row_num
					
from Portfolio..nashvilleHousing
--order by ParcelID
)
select * from rownumCTE
where row_num>1
order by PropertyAddress




---Delete unsed columns


select *
from Portfolio..nashvilleHousing

alter table Portfolio..nashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table Portfolio..nashvilleHousing
drop column SaleDate
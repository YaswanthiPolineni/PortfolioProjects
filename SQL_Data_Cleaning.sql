--Data Cleaning

exec sp_rename 'Nashville Housing Data for Data Cleaning', 'NashvilleHousing'

select * from NashvilleHousing

--Standardize Date Format
select SaleDate, convert(Date, SaleDate) from NashvilleHousing

update NashvilleHousing set SaleDate=convert(Date, SaleDate)

--Populate Property Address Data- Properties with same Parcel Id has Same Address- Self join

select * from NashvilleHousing
where propertyAddress is null
order by parcelid

select N1.ParcelId, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, isnull(N1.propertyAddress,N2.propertyAddress) as PropertyAddress1
from NashvilleHousing N1 join NashvilleHousing N2 
on N1.parcelId=N2.ParcelId and N1.uniqueId<>N2.uniqueId 
where N1.propertyAddress is Null

update N1
set PropertyAddress=isnull(N1.propertyAddress,N2.propertyAddress) 
from NashvilleHousing N1 join NashvilleHousing N2 
on N1.parcelId=N2.ParcelId and N1.uniqueId<>N2.uniqueId 
where N1.propertyAddress is Null


select * from NashvilleHousing
order by parcelid

--Breaking out Address into Individual columns (Address, City State)
select propertyaddress from NashvilleHousing

select substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add Address nvarchar(255), City varchar(255)

UPDATE NashvilleHousing
SET Address = substring(propertyaddress,1,charindex(',',propertyaddress)-1), 
City = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

Select * from NashvilleHousing


--Owner Address

select owneraddress from NashvilleHousing

select parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1) 
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(50)

UPDATE NashvilleHousing
SET OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3), 
OwnerSplitCity = parsename(replace(owneraddress,',','.'),2),
OwnerSplitState= parsename(replace(owneraddress,',','.'),1)

Select * from NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(soldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant


select SoldAsVacant, 
case 
 when SoldAsVacant='N' then 'No'
 when SoldAsVacant='Y' then 'Yes'
 else SoldAsVacant
End as NewSoldAsVacant
from NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = case 
 when SoldAsVacant='N' then 'No'
 when SoldAsVacant='Y' then 'Yes'
 else SoldAsVacant 
 end


--Remove Duplicates Using CTE
with RowNumCTE as (
    select *, row_number() over(
        partition by ParcelId, PropertyAddress, SalePrice, SaleDate,LegalReference order by uniqueId) row_num
        from  NashvilleHousing
    )
delete
from RowNumCTE where row_num>1

with RowNumCTE as (
    select *, row_number() over(
        partition by ParcelId, PropertyAddress, SalePrice, SaleDate,LegalReference order by uniqueId) row_num
        from  NashvilleHousing
    )
select *
from RowNumCTE where row_num>1


--Delete UnUsed Columns- Dont do this to Raw data

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select *
from NashvilleHousing


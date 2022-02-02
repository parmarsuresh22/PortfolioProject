/*
Cleaning Data in SQL Queries
*/

Select *
From portfolio3.nash_csv

-- Standardize Date Format
SELECT SaleDate, date_format(SaleDate, '%d-%m-%Y') as ConvSaleDate
from portfolio3.nash_csv

alter table portfolio3.nash_csv 
add ConvSaleDate varchar(10) after SaleDate

Update portfolio3.nash_csv 
set ConvSaleDate = date_format(SaleDate, '%d-%m-%Y')

-- Populate Property Address data
select *
from portfolio3.nash_csv nc 
-- where PropertyAddress is null
order by ParcelID 

select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress) 
from portfolio3.nash_csv a
join portfolio3.nash_csv b 
on a.ParcelID = b.ParcelID 
and a.Unique_ID <> b.Unique_ID 
where a.PropertyAddress is null

Update portfolio3.nash_csv a
JOIN portfolio3.nash_csv b
on a.ParcelID = b.ParcelID
AND a.Unique_ID <> b.Unique_ID 
set a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress 
from portfolio3.nash_csv nc 
-- where PropertyAddress is null
-- order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, locate(',', PropertyAddress) +1) as Address
From portfolio3.nash_csv nc 

alter table portfolio3.nash_csv 
add PropertySplitAddress varchar(42) after PropertyAddress

update portfolio3.nash_csv 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 )

alter table portfolio3.nash_csv 
add PropertySplitCity varchar(42) after PropertySplitAddress

update portfolio3.nash_csv 
set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) +1)

select *
from portfolio3.nash_csv

select OwnerAddress
from portfolio3.nash_csv

select
substring_index(OwnerAddress, ',', 1),
substring_index(substring_index(OwnerAddress, ',', 2),',', -1),
substring_index(OwnerAddress, ',', -1)
from portfolio3.nash_csv

ALTER TABLE portfolio3.nash_csv 
Add OwnerSplitAddress varchar(46) after OwnerAddress

Update portfolio3.nash_csv 
SET OwnerSplitAddress = substring_index(OwnerAddress, ',', 1)

ALTER TABLE portfolio3.nash_csv 
Add OwnerSplitCity varchar(46) after OwnerSplitAddress

Update portfolio3.nash_csv 
SET OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2),',', -1)

ALTER TABLE portfolio3.nash_csv 
Add OwnerSplitState varchar(46) after OwnerSplitCity

Update portfolio3.nash_csv 
SET OwnerSplitState = substring_index(OwnerAddress, ',', -1)

select *
from portfolio3.nash_csv

-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio3.nash_csv
group by SoldAsVacant 
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from portfolio3.nash_csv

update portfolio3.nash_csv 
set SoldAsVacant = 
case when SoldAsVacant = 'y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end

-- Remove Duplicates
select *, count(*) as row_num
from portfolio3.nash_csv
group by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
having row_num > 1

delete a
from portfolio3.nash_csv a
inner join portfolio3.nash_csv b 
on a.Unique_ID < b.Unique_ID 
where a.ParcelID = b.ParcelID 

select *
from portfolio3.nash_csv

-- Delete Unused Columns
Select *
From portfolio3.nash_csv

alter table portfolio3.nash_csv
drop column OwnerAddress

alter table portfolio3.nash_csv
drop column SaleDate,
drop column TaxDistrict,
drop column PropertyAddress


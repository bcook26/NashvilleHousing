/*
 Bryce Cook
 Data Cleaning Project using SQL queries
 */
----------------------------------------
select count(*)
from nashvillehousing n 

select * 
from nashvillehousing n 

----------------------------------------
--Standardizing Sale Date
select saledate
from nashvillehousing n 

update nashvillehousing 
set saledate = saledate::date

----------------------------------------
-- updating year built
alter table nashvillehousing 
add YearBuiltNew varchar(255)

update nashvillehousing 
set YearBuiltNew = substring(yearbuilt, 1, strpos(yearbuilt ,'-') - 1)


-- Populate property address (convert empty to null first)
----------------------------------------
update nashvillehousing 
set propertyaddress = null
where propertyaddress = ''

-- sanity check for nulls
select propertyaddress
from nashvillehousing n 
where propertyaddress is null


select n.parcelid, n2.propertyaddress, n2.parcelid, n2.propertyaddress, 
	   coalesce (n.propertyaddress, n2.propertyaddress)
from nashvillehousing n
join nashvillehousing n2
	on n.parcelid = n2.parcelid 
	and n."UniqueID " <> n2."UniqueID "
where n.propertyaddress is null


UPDATE nashvillehousing AS h1
SET propertyaddress = h2.propertyaddress
FROM nashvillehousing AS h2
WHERE h1.parcelid = h2.parcelid AND h1."UniqueID " <> h2."UniqueID "
  								AND h1.propertyaddress IS NULL AND h2.propertyaddress IS NOT NULL

 
----------------------------------------
-- Breaking out address into individual columns (address, city, state)
select propertyaddress
from nashvillehousing n

select 
substring(propertyaddress, 1, strpos(propertyaddress,',') - 1) as Address,
substring(propertyaddress, strpos(propertyaddress, ',') + 1, length(propertyaddress)) as City
from nashvillehousing n 

-- Adding new split columns into table 

alter table nashvillehousing 
add PropertySplitAddress varchar(255)

update nashvillehousing 
set PropertySplitAddress = substring(propertyaddress, 1, strpos(propertyaddress,',') - 1)

alter table nashvillehousing 
add PropertySplitCity varchar(255)

update nashvillehousing 
set PropertySplitCity = substring(propertyaddress, strpos(propertyaddress, ',') + 1, length(propertyaddress))



select owneraddress
from nashvillehousing n 

select 
split_part(owneraddress::text, ',', 1) as OwnerAddress,
split_part(owneraddress::text, ',', 2) as OwnerCity,
split_part(owneraddress::text, ',', 3) as OwnerState 
from nashvillehousing n  


alter table nashvillehousing 
add OwnerSplitAddress varchar(255)

alter table nashvillehousing 
add OwnerSplitCity varchar(255)

alter table nashvillehousing 
add OwnerSplitState varchar(255)


update nashvillehousing 
set OwnerSplitAddress = split_part(owneraddress::text, ',', 1)

update nashvillehousing 
set OwnerSplitCity = split_part(owneraddress::text, ',', 2)

update nashvillehousing 
set OwnerSplitState = split_part(owneraddress::text, ',', 3)


----------------------------------------
-- change y and n -> yes and no =

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing n 
group by soldasvacant 
order by 2 

select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
	   when soldasvacant = 'N' then 'No'
	   else soldasvacant 
	   end
from nashvillehousing n 


update nashvillehousing 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	   					when soldasvacant = 'N' then 'No'
	   					else soldasvacant 
	   					end


----------------------------------------
-- Removing duplicates (using cte)

with RowNumCTE as(
select parcelid 
	   from (
	   		select
	   			parcelid,
		row_number() over(
		partition by parcelid,
					 propertyaddress,
					 saleprice,
					 saledate,
					 legalreference
					 order by 
					 	"UniqueID "
					 ) as row_num
				from nashvillehousing n
			) s 
			where row_num > 1
)
delete from nashvillehousing 
where parcelid in (select * from RowNumCTE)

----------------------------------------
-- deleting unused columns

alter table nashvillehousing 
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress

alter table nashvillehousing 
drop column yearbuilt


show DATA_DIRECTORY


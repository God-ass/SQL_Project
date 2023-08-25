--Investigate data
SELECT *
FROM Project..Housing
ORDER BY 1


--Investigate Data Types
USE Project
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Housing';


-- Standardize Date Format
ALTER TABLE Project..Housing 
ALTER COLUMN Sale_Date date;


--Change Column Name with space
--RENAME Function isn't executable
EXEC sp_rename 'Project..Housing.[Property Address]', 'Property_Address', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Sale Date]', 'Sale_Date', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Sale Price]', 'Sale_Price', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Legal Reference]', 'Legal_Reference', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Sold As Vacant]', 'Sold_As_Vacant', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Owner Name]', 'Owner_Name', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Owner Address]', 'Owner_Address', 'COLUMN';
EXEC sp_rename 'Project..Housing.[Tax District]', 'Tax_District', 'COLUMN';

 

-- Replace NULL in Property Address data
SELECT *
FROM Project..Housing
WHERE Property_Address IS NULL
ORDER BY ParcelID;

--We are going to use b.Property_Address to replace NULL where a.ParcelID = b.ParcelID (LOOK AT THE DATA)
SELECT a.ParcelID, a.Property_Address, a.[UniqueID ],b.[UniqueID ], b.ParcelID, b.Property_Address, ISNULL(a.Property_Address,b.Property_Address)
FROM Project..Housing a
JOIN Project..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--Where a.Property_Address IS NULL

UPDATE a
SET Property_Address = COALESCE(a.Property_Address,b.Property_Address)
FROM Project..Housing a
JOIN Project..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.Property_Address IS NULL


--Split Address into 3 columns: Address, City, State
SELECT Property_Address
FROM Project..Housing
ORDER BY ParcelID

SELECT SUBSTRING(Property_Address, 1, CHARINDEX(',', Property_Address)-1),
		SUBSTRING(Property_Address, CHARINDEX(',', Property_Address)+1, LEN(Property_Address))
FROM Project..Housing;

ALTER TABLE Project..Housing
ADD Prop_Address Nvarchar(255);

UPDATE Project..Housing
SET Prop_Address = SUBSTRING(Property_Address, 1, CHARINDEX(',', Property_Address)-1);

ALTER TABLE Project..Housing
ADD Prop_City Nvarchar(255);

UPDATE Project..Housing
SET Prop_City = SUBSTRING(Property_Address, CHARINDEX(',', Property_Address)+1, LEN(Property_Address));

SELECT Owner_Address
FROM Project..Housing

ALTER TABLE Project..Housing
ADD Own_Address Nvarchar(255);

UPDATE Project..Housing
SET Own_Address = PARSENAME(REPLACE(Owner_Address, ',', '.'), 3);

ALTER TABLE Project..Housing
ADD Own_City Nvarchar(255);

UPDATE Project..Housing
SET Own_City = PARSENAME(REPLACE(Owner_Address, ',', '.') , 2);

ALTER TABLE Project..Housing
ADD Own_State Nvarchar(255);

Update Project..Housing
SET Own_State = PARSENAME(REPLACE(Owner_Address, ',', '.') , 1);

-- Change Y and N to Yes and No in Sold_As_Vacant column
SELECT DISTINCT(Sold_As_Vacant), Count(Sold_As_Vacant) AS count
FROM Project..Housing
GROUP BY Sold_As_Vacant
ORDER BY count

UPDATE Housing
SET Sold_As_Vacant = CASE WHEN Sold_As_Vacant = 'Y' THEN 'Yes'
	   WHEN Sold_As_Vacant = 'N' THEN 'No'
	   ELSE Sold_As_Vacant
	   END


-- Remove Duplicates Records
WITH RowCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 Property_Address,
				 Sale_Price,
				 Sale_Date,
				 Legal_Reference
				 ORDER BY
					UniqueID
					) row_num
FROM Project..Housing
--order by ParcelID
)
DELETE
FROM RowCTE
WHERE row_num > 1

--Check if the duplicates still exist
WITH RowCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 Property_Address,
				 Sale_Price,
				 Sale_Date,
				 Legal_Reference
				 ORDER BY
					UniqueID
					) row_num
FROM Project..Housing
--order by ParcelID
)
SELECT *
FROM RowCTE
WHERE row_num > 1


-- Delete Unused Columns
ALTER TABLE Project..Housing
DROP COLUMN Owner_Address, Tax_District, Property_Address, Sale_Date;

-- Here is the finalized data, ready to used!
SELECT *
FROM Project..Housing

# Data Cleaning in SQL
In this project, we employ raw Nashville housing data and transform it in SQL Server to make it more usable for analysis.

## About this project
- `Rename column names with spaces` for convenience.
- Used `ALTER TABLE` to standardize date formats and delete unused columns. 
- Used `JOIN` to replace NULL values in Property_Address.
- `Split Address into 3 separate columns`: Address, City, and State and used `UPDATE TABLE` to store the splited result.
- Used `aggregate functions` to convert ‘Y’ and ‘N’ to Yes and No in the Sold_As_Vacant column.
- Leveraged `Common Table Expressions (CTEs)` and `window functions (ROW_NUMBER)` to remove duplicate records.

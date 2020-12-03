/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5 pts): What function can you use to show a list of Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

-- <Put Your Code Here> --
Select
    vProducts.ProductName,
    UnitPrice = Format(vProducts.UnitPrice, 'C','en-us')
from vProducts
Order By 1;    
go

-- Question 2 (10 pts): What function can you use to show a list of Category and Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the Category and Product!

-- <Put Your Code Here> --
Select
    vCategories.CategoryName, 
    vProducts.ProductName,
    UnitPrice = Format(vProducts.UnitPrice, 'C', 'en-us')
From vProducts 
    Inner join vCategories
        On vProducts.CategoryID = vCategories.CategoryID
Order by 1, 2, 3;
go

-- Question 3 (10 pts): What function can you use to show a list of Product names, 
-- each Inventory Date, and the Inventory Count, with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

-- <Put Your Code Here> --
Select
    vProducts.ProductName, 
    [InventoryDate] = DATENAME(MM, vInventories.InventoryDate) + ',' + DATENAME(YY, vInventories.InventoryDate),
    [InventoryCount]= vInventories.[Count]
From vProducts 
    Inner join vInventories
        On vProducts.ProductID = vInventories.ProductID
Order by 1, 2, 3;
go

-- Question 4 (10 pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

-- <Put Your Code Here> --
CREATE
VIEW vProductInventories
AS
    Select Top 1000000
    vProducts.ProductName,
    [InventoryDate] = DATENAME(MM, vInventories.InventoryDate) + ',' + DATENAME(YY, vInventories.InventoryDate),
    [InventoryCount]= vInventories.[Count]
From vProducts 
    Inner join vInventories
        On vProducts.ProductID = vInventories.ProductID
Order by 1, Month([InventoryDate]), 3;
go

Select * From vProductInventories;


-- Question 5 (15 pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

-- <Put Your Code Here> --
CREATE
View vCategoryInventories
AS
    Select Top 1000000
    vCategories.CategoryName,
    [InventoryDate] = DATENAME(MM, vInventories.InventoryDate) + ',' + DATENAME(YY, vInventories.InventoryDate),
    [InventoryCountByCategory]= Sum(vInventories.[Count])
    From vCategories 
    Inner join vProducts
        On vProducts.CategoryID = vCategories.CategoryID
    Inner join vInventories
        On vProducts.ProductID = vInventories.ProductID
    Group By vCategories.CategoryName, InventoryDate  
    Order by CategoryName, Month([InventoryDate]), InventoryCountByCategory ;
go

Select * From vCategoryInventories;

-- Question 6 (10 pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

-- <Put Your Code Here> --
CREATE
View vProductInventoriesWithPreviouMonthCounts
AS
    Select Top 1000000
    ProductName,
    InventoryDate,
    InventoryCount,
    [PreviousMonthCount] = IsNull (Lag(InventoryCount) Over (Order By ProductName, Year(InventoryDate)), 0)
    From vProductInventories
    Order by 1, Month([InventoryDate]), 3 ;
go

Select * From vProductInventoriesWithPreviouMonthCounts;

-- Question 7 (15 pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the Product, Date, and Count!

-- <Put Your Code Here> --
CREATE
View vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
    Select Top 1000000
    ProductName,
    InventoryDate,
    InventoryCount,
    [PreviousMonthCount],
    [CountVsPreviousCountKPI] = IsNull( Case
        When InventoryCount>[PreviousMonthCount] Then 1
        When InventoryCount = [PreviousMonthCount] Then 0
        When InventoryCount < [PreviousMonthCount] Then -1
        End, 0 )
    From vProductInventoriesWithPreviouMonthCounts
    Order by 1, Month([InventoryDate]), 3 ;
go

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

-- Question 8 (25 pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

-- <Put Your Code Here> --
CREATE
Function fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIValue Int)
Returns Table
AS
  Return Select
        ProductName,
        InventoryDate,
        InventoryCount,
        [PreviousMonthCount],
        [CountVsPreviousCountKPI] 
    From vProductInventoriesWithPreviousMonthCountsWithKPIs
    Where [CountVsPreviousCountKPI] = @KPIValue;
go


/* Check that it works*/
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go
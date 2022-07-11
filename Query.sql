-- 1.
SELECT ItemName, ItemPrice,
SUM(Qty) AS [Item Total]
FROM Item I
	JOIN PurchaseDetail PD ON PD.ItemId = I.ItemId
	JOIN PurchaseHeader PH ON PD.PurchaseId = PH.PurchaseId
WHERE PH.ArrivalDate IS NULL
GROUP BY ItemName, ItemPrice
HAVING SUM(QTY) > 100
ORDER BY [Item Total] DESC
GO

-- 2.
SELECT VendorName, SUBSTRING(VendorEmail,CHARINDEX('@', VendorEmail) + 1,LEN(VendorEmail)) AS [Domain Name], AVG(Qty) AS [Average Purchased Item]
FROM Vendor V
	JOIN PurchaseHeader PH ON V.VendorId = PH.VendorId
	JOIN PurchaseDetail PD ON PH.PurchaseId = PD.PurchaseId
WHERE VendorAddress LIKE '%Food Street%' AND SUBSTRING(VendorEmail,CHARINDEX('@', VendorEmail) + 1,LEN(VendorEmail)) NOT LIKE 'gmail.com'
GROUP BY VendorName, SUBSTRING(VendorEmail,CHARINDEX('@', VendorEmail) + 1,LEN(VendorEmail))
GO

-- 3.
SELECT DATENAME(MONTH,SalesDate) AS [Month], MIN(Qty) AS [Minimum Quantity Sold], MAX(Qty) AS [Maximum Quantity Sold]
FROM SalesHeader SH
	JOIN SalesDetail SD ON SH.SalesId = SD.SalesId
	JOIN Item I ON I.ItemId = SD.ItemId
	JOIN ItemType IT ON I.ItemTypeId = IT.ItemTypeId
WHERE YEAR(SalesDate) = 2019 AND ItemTypeName NOT IN ('Food', 'Drinks')
GROUP BY DATENAME(MONTH,SalesDate)
GO

-- 4
SELECT REPLACE(sh.StaffId , 'ST', 'Staff')  , StaffName, [Salary]= CONCAT('Rp. ' ,StaffSalary), COUNT(sh.SalesId) as [Sales Count], AVG(Qty) as [Average Sales Quantity]
FROM Staff st
	JOIN SalesHeader sh on st.StaffId = sh.StaffId
	JOIN SalesDetail sd on sh.SalesId = sd.SalesId
	JOIN Customer cs on cs.CustomerId = sh.CustomerId
WHERE (CustomerGender = 'Male' and StaffGender = 'Female') or (CustomerGender = 'Female' and StaffGender = 'Male') and MONTH(SalesDate) = 2  
GROUP BY REPLACE(sh.StaffId , 'ST', 'Staff') , StaffName, CONCAT('Rp. ' ,StaffSalary) 
GO

--5
SELECT LEFT(CustomerName,1)+RIGHT(CustomerName,1) AS [Customer Initial], CONVERT(VARCHAR, SalesDate, 107) AS [Transaction Date], Qty AS [Quantity]
FROM Customer C
	JOIN SalesHeader SH ON C.CustomerID = SH.CustomerID
	JOIN SalesDetail SD ON SH.SalesId = SD.SalesId,
(
    SELECT 
        AVG(x.Qty) AS [AverageQuantity]
    FROM (
        SELECT Qty
        FROM SalesHeader SH 
            JOIN SalesDetail SD ON SH.SalesId = SD.SalesId
    )x
)y
WHERE Qty > y.AverageQuantity AND CustomerGender = 'Female'
GO

---6 
SELECT VendorId = LOWER(vd.VendorId), VendorName, [Phone Number] = STUFF(VendorPhone, 1 , 1, '+62')
FROM Vendor vd JOIN PurchaseHeader ph ON vd.VendorId = ph.VendorId
   JOIN PurchaseDetail pd ON pd.PurchaseId = ph.PurchaseId
WHERE CONVERT(int,RIGHT(ph.PurchaseId,3))%2=0 and Qty>(
   SELECT MIN(Minimal)
   FROM (
       SELECT Minimal = SUM(Qty)
       FROM Vendor vd JOIN PurchaseHeader ph ON vd.VendorId = ph.VendorId
      JOIN PurchaseDetail pd ON pd.PurchaseId = ph.PurchaseId
       GROUP BY ph.PurchaseId
   )AS Minimalis
) 
GO

--7
SELECT
StaffName,
VendorName,
PD.PurchaseId,
SUM(Qty) AS [Total Purchased Quantity],
CONCAT(DATEDIFF (day, PurchaseDate, GETDATE()), ' Days ago') AS [Ordered Day] 
FROM Staff S
JOIN PurchaseHeader PH ON PH.StaffId = S.StaffId
JOIN Vendor V ON V.VendorId = PH.VendorId
JOIN PurchaseDetail PD ON PD.PurchaseId = PH.PurchaseId,
(
    SELECT x.[Maximum Quantity] AS [Maximum Quantity]
    FROM(
        SELECT MAX(Qty) AS [Maximum Quantity]
        FROM PurchaseDetail
    )x
        
)y
WHERE DATEDIFF (day, PurchaseDate, ArrivalDate) < 7
GROUP BY StaffName, VendorName, PD.PurchaseId, CONCAT(DATEDIFF (day, PurchaseDate, GETDATE()), ' Days ago'), y.[Maximum Quantity]
HAVING SUM(Qty) > y.[Maximum Quantity]
GO

--8
SELECT TOP 2
DATENAME(WEEKDAY, SalesDate) AS [Day] ,
COUNT(*) AS [Item Sales Amount]
FROM SalesHeader SH
JOIN SalesDetail SD ON SH.SalesId = SD.SalesId
JOIN Item I ON I.ItemId = SD.ItemId
JOIN ItemType IT ON IT.ItemTypeId = I.ItemTypeId,
(    
    SELECT AVG(ItemPrice) AS [Average Price]
    FROM Item I
        JOIN ItemType IT ON IT.ItemTypeId = I.ItemTypeId
    WHERE ItemTypeName IN ('Electronic', 'Gadget')
)y
WHERE ItemPrice < y.[Average Price]
GROUP BY DATENAME(WEEKDAY, SalesDate)
ORDER BY [Item Sales Amount] ASC
GO

--9
CREATE VIEW [Customer Statistic by Gender] AS
SELECT CustomerGender , [Minimun Quantity] = MIN(QTY) , [Maximum Quantity] = MAX(QTY)
FROM Customer CS , SalesHeader SH , SalesDetail SD
WHERE CS.CustomerID = SH.CustomerID AND
	SH.SalesId = SD.SalesId AND
	CustomerDOB BETWEEN '1998/01/01' AND '1999/12/31'
	AND QTY BETWEEN 10 AND 50
GROUP BY CustomerGender
GO
SELECT * FROM [Customer Statistic by Gender]
GO

--10
CREATE VIEW [Item Type Statistic] AS
SELECT [Item Type] = UPPER(IT.ItemTypeName), [AVG]=AVG(ItemPrice) , [Number of Item Variety] = COUNT(I.ItemTypeId) 
FROM Item I , ItemType IT 
WHERE I.ItemTypeId = IT.ItemTypeId AND 
	LEFT(ItemTypeName , 1) = 'F' AND
	I.MinimumPurchase > 5
GROUP BY UPPER(ItemTypeName)
	
SELECT * FROM [Item Type Statistic]


CREATE DATABASE DbProjectE
GO 
USE DbProjectE
GO
--DROP DATABASE DbProjectE
CREATE TABLE Customer (
	CustomerID CHAR(5) PRIMARY KEY CHECK (CustomerID LIKE 'CU[0-9][0-9][0-9]'),
	CustomerName VARCHAR(50) NOT NULL,
	CustomerGender VARCHAR(6) CHECK (CustomerGender LIKE 'Male' or CustomerGender LIKE 'Female') NOT NULL,
	CustomerPhone VARCHAR(14) NOT NULL,
	CustomerDOB DATE NOT NULL
)

CREATE TABLE Staff (
	StaffId CHAR(5) PRIMARY KEY CHECK (StaffId LIKE 'ST[0-9][0-9][0-9]'),
	StaffName VARCHAR(50) NOT NULL,
	StaffGender VARCHAR(6) CHECK (StaffGender LIKE 'Male' or StaffGender LIKE 'Female') NOT NULL,
	StaffPhone VARCHAR(14) NOT NULL,
	StaffSalary INT NOT NULL
)

CREATE TABLE ItemType(
	ItemTypeId CHAR(5) PRIMARY KEY CHECK(ItemTypeId LIKE 'IP[0-9][0-9][0-9]'),
	ItemTypeName VARCHAR(255) CHECK(LEN(ItemTypeName) >= 4) NOT NULL
)

CREATE TABLE Item(
	ItemId CHAR(5) PRIMARY KEY CHECK(ItemId LIKE 'IT[0-9][0-9][0-9]'),
	ItemTypeId CHAR(5) FOREIGN KEY REFERENCES ItemType(ItemTypeId) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	ItemName VARCHAR(255) NOT NULL,
	ItemPrice INT CHECK(ItemPrice > 0) NOT NULL,
	MinimumPurchase INT NOT NULL
)

CREATE TABLE SalesHeader(
	SalesId CHAR(5) PRIMARY KEY CHECK (SalesId LIKE'SA[0-9][0-9][0-9]') NOT NULL,
	StaffId CHAR(5) FOREIGN KEY references Staff(StaffId)NOT NULL ,
	CustomerID CHAR(5) FOREIGN KEY references Customer(CustomerID) NOT NULL,
	SalesDate Date NOT NULL
)

CREATE TABLE SalesDetail (
	SalesId CHAR(5) FOREIGN KEY references  SalesHeader(SalesId),
	ItemId CHAR(5) FOREIGN KEY references Item(ItemId),
	Qty INT NOT NULL,
	PRIMARY KEY (SalesId,ItemId)
)

CREATE TABLE Vendor (
	VendorId CHAR(5) PRIMARY KEY CHECK(VendorId LIKE 'VE[0-9][0-9][0-9]') ,
	VendorName CHAR(255) NOT NULL,
	VendorPhone VARCHAR(255) NOT NULL,
	VendorAddress VARCHAR(255) CHECK (VendorAddress LIKE '%Street')NOT NULL,
	VendorEmail VARCHAR(255) CHECK (VendorEmail LIKE '%@%.com') NOT NULL
)

CREATE TABLE PurchaseHeader (
	PurchaseId CHAR(5) PRIMARY KEY CHECK(PurchaseId LIKE 'PH[0-9][0-9][0-9]') ,
	StaffId CHAR(5) REFERENCES Staff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE,
	VendorId CHAR(5) REFERENCES Vendor ON UPDATE CASCADE ON DELETE CASCADE,
	PurchaseDate DATE NOT NULL,
	ArrivalDate DATE 
)

CREATE TABLE PurchaseDetail(
	PurchaseId CHAR(5) REFERENCES PurchaseHeader(PurchaseId) ON UPDATE CASCADE ON DELETE CASCADE,
	ItemId CHAR(5) REFERENCES Item(ItemId) ON UPDATE CASCADE ON DELETE CASCADE,
	Qty INT NOT NULL,
	PRIMARY KEY(PurchaseId, ItemId)
)
USE DbProjectE
----------------------------------
-- SIMULASI TERJADINYA PURCHASE --
----------------------------------

-- Ketika ingin melakukan Purchase baru dari Vendor baru (tidak pernah terdaftar sebelumnya) :

-- Mendata sebuah vendor baru (Id : VE011)

INSERT INTO Vendor VALUES 
	('VE011', 'SegarSariDoger', '08332453422', 'Es Doger Street','mintaangin@gmail.com')
	

-- Staff (ST008),(ST009) Membeli item dari vendor baru tersebut (VE011)

-- PH016 ArrivalDate masih belum sampai

INSERT INTO PurchaseHeader VALUES 
	('PH016', 'ST008', 'VE011', '2021-01-13', NULL),
	('PH017', 'ST009', 'VE011', '2021-12-12', '2021-12-18')


-- Buat Trigger untuk mengupdate stock jika sebuah purchase sudah sampai (langsung sampai tanpa diupdate)
CREATE TRIGGER StoreToStock ON PurchaseDetail FOR INSERT
AS
BEGIN
	DECLARE ItemCursor CURSOR SCROLL FOR
	SELECT PurchaseId, ItemId, Qty
	FROM inserted
	
	OPEN ItemCursor

	DECLARE @PurchaseId CHAR(5), @ItemId CHAR(5), @Qty INT

	FETCH FIRST FROM ItemCursor INTO @PurchaseId, @ItemId, @Qty
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @ArrivalDate DATE
			SELECT @ArrivalDate = ArrivalDate
			FROM PurchaseHeader
			WHERE @PurchaseId = PurchaseHeader.PurchaseId

			IF @ArrivalDate IS NOT NULL
			BEGIN
				UPDATE Item
				SET Stock = Stock + @Qty
				WHERE Item.ItemId = @ItemId
			END		
			
			FETCH NEXT FROM ItemCursor INTO @PurchaseId, @ItemId, @Qty
		END


	CLOSE ItemCursor
	DEALLOCATE ItemCursor	
END
GO

-- Buat Trigger untuk mengupdate stock sebuah purchase yang diupdate karena baru sampai.
GO
CREATE TRIGGER UpdateStoreToStock ON PurchaseHeader FOR UPDATE
AS
BEGIN
	DECLARE @afterUpdate DATE, @beforeUpdate DATE

	SELECT @beforeUpdate = deleted.ArrivalDate
	FROM deleted

	SELECT @afterUpdate = inserted.ArrivalDate
	FROM inserted

	IF @beforeUpdate IS NULL AND @afterUpdate IS NOT NULL
	BEGIN

		DECLARE ItemCursor CURSOR SCROLL FOR
			SELECT ItemId, Qty
			FROM PurchaseDetail PD, inserted i
			WHERE PD.PurchaseId = i.PurchaseId

		OPEN ItemCursor

		DECLARE @ItemId CHAR(5), @Qty INT


		FETCH FIRST FROM ItemCursor INTO @ItemId, @Qty
		WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE Item
				SET Stock = Stock + @Qty
				WHERE ItemId = @ItemId
				FETCH NEXT FROM ItemCursor INTO @ItemId, @Qty
			END

		CLOSE ItemCursor
		DEALLOCATE ItemCursor
	END
END
GO

-- Detail jumlah barang yang dibeli oleh staff 

INSERT INTO PurchaseDetail VALUES
	('PH016' , 'IT039' , 30), --Kelengkeng
	('PH016' , 'IT031' , 15), --IPOPhone
	('PH016' , 'IT021' , 5), --Teh Alakadarnya 
	('PH016' , 'IT001' , 20), --Strawberry Chocolate Ice Cream 
	('PH016' , 'IT004' , 40), --Beras Putih 1kg
	('PH016' , 'IT005' , 70), --Tolak Angin Reguler
	('PH016' , 'IT020' , 30), --Naga Manis Asem
	('PH016' , 'IT022' , 94), --Roma Kelapa Alakadarnya
	('PH017' , 'IT024' , 70), --Permen Kaki Hijau
	('PH017' , 'IT002' , 25), --Teh Kantong Bunda Sari Murni
	('PH017' , 'IT025' , 35), --Spaghetti
	('PH017' , 'IT007' , 75), --Luwak White Coffee
	('PH017' , 'IT015' , 15), --Bodrex Sakit Kepala 8 Pill
	('PH017' , 'IT013' , 55), --Sari Roti 10 Slice
	('PH017' , 'IT012' , 70) --Sprite 1L
GO

-- Item yang ada di PH016 tidak akan mengupdate stock karena arrival date masih NULL

-- Ketika ArrivalDate sudah tidak NULL, maka stock semua item di PH016 akan bertambah

UPDATE PurchaseHeader
	SET	ArrivalDate = '2021-12-20'
	WHERE PurchaseId = 'PH016'

-------------------------------
-- SIMULASI TERJADINYA SALES --
-------------------------------

-- Ketika ada Sales Baru terjadi dan customer baru (tidak pernah terdaftar sebelumnya) :

-- mendata customer baru (Id baru nya CU011)

INSERT INTO Customer VALUES 
		('CU011', 'Michael', 'Male','088124563422', '2002-05-10')

-- customer CU011 ini membeli sesuatu oleh Staff ST003

INSERT INTO SalesHeader VALUES
	('SA016', 'ST003', 'CU011','2021-12-12')

-- Membuat Trigger Update Stok saat customer membeli sesuatu
GO

CREATE TRIGGER TakeFromStock ON SalesDetail FOR INSERT AS
BEGIN
	DECLARE ItemCursor CURSOR SCROLL FOR
	SELECT SalesId, ItemId, Qty
	FROM inserted

	OPEN ItemCursor
	DECLARE @SalesId CHAR(5), @ItemId CHAR(5), @Qty INT
	FETCH FIRST FROM ItemCursor INTO @SalesId, @ItemId, @Qty
	WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Item
        SET Stock = Stock - @Qty
        WHERE Item.ItemId = @ItemId
        FETCH NEXT FROM ItemCursor INTO @SalesId, @ItemId, @Qty
    END
	CLOSE ItemCursor
	DEALLOCATE ItemCursor
END
GO

-- customer CU011 membeli beberapa barang

INSERT INTO SalesDetail VALUES
	('SA016', 'IT007', 15), -- Luwak White Coffee
	('SA016', 'IT012', 1), -- Sprite 1L 
	('SA016', 'IT023', 2), -- Beras Bulog
	('SA016', 'IT010', 9), -- Indomie Goreng Reguler
	('SA016', 'IT019', 3) --Craft Keju Godzilla


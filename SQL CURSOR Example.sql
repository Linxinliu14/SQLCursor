Use AdventureWorks2017;

SELECT DISTINCT SalesOrderID,
STUFF((SELECT  ', '+RTRIM(CAST(ProductID as char))  
       FROM Sales.SalesOrderDetail d1
       WHERE d1.SalesOrderID = d2.SalesOrderID
       ORDER BY ProductID
       FOR XML PATH('')) , 1, 2, '') AS Products
FROM Sales.SalesOrderDetail d2
ORDER BY SalesOrderID;

/*
43659	709, 711, 712, 714, 716, 771, 772, 773, 774, 776, 777, 778
43660	758, 762
43661	708, 711, 712, 715, 716, 741, 742, 743, 745, 747, 773, 775, 776, 777, 778
43662	722, 725, 726, 729, 730, 732, 733, 738, 749, 753, 754, 755, 756, 758, 760, 762, 763, 764, 765, 766, 768, 770
43663	760
43664	714, 716, 771, 772, 773, 775, 777, 778*/

/* SQL CURSOR Example */

DECLARE @list varchar(1000) = '';
DECLARE @ordid int;
DECLARE @EmailAdd varchar(50);
DECLARE @subj varchar(20);

CREATE TABLE #temp
(OrderID int,
 Email varchar(50),
 Products varchar(1000));

DECLARE ord_cursor CURSOR FOR  
     SELECT SalesOrderID, EmailAddress
     FROM Sales.SalesOrderHeader soh
	 JOIN Sales.Customer c
	 ON soh.CustomerID = c.CustomerID
	 JOIN Person.EmailAddress e
	 ON c.PersonID = e.BusinessEntityID
     ORDER BY SalesOrderID;

OPEN ord_cursor;
FETCH NEXT FROM ord_cursor INTO @ordid, @EmailAdd;  

WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @list  = '';

   SELECT @list = @list + ' ' + RTRIM(CAST(ProductID as char)) + ',' 
   FROM Sales.SalesOrderDetail 
   WHERE SalesOrderID = @ordid
   ORDER BY ProductID;

   SELECT @list = LTRIM(LEFT(@list, LEN(@list) -1));

   INSERT INTO #temp
   VALUES (@ordid, @EmailAdd, @list);

   --SET @subj = 'Products contained in ' + CAST(@ordid AS char);  
   --EXEC msdb.dbo.sp_send_dbmail  
   -- @profile_name = 'simon',  -- ex07 Exchange Server
   -- @recipients = @EmailAdd,  
   -- @body = @list,  
   -- @subject = @subj;  

   FETCH NEXT FROM ord_cursor INTO @ordid, @EmailAdd;   
END   

CLOSE ord_cursor;   
DEALLOCATE ord_cursor; 

SELECT * FROM #temp;
/*
43659	james9@adventure-works.com	709, 711, 712, 714, 716, 771, 772, 773, 774, 776, 777, 778
43660	takiko0@adventure-works.com	758, 762
43661	jauna0@adventure-works.com	708, 711, 712, 715, 716, 741, 742, 743, 745, 747, 773, 775, 776, 777, 778
43662	robin0@adventure-works.com	722, 725, 726, 729, 730, 732, 733, 738, 749, 753, 754, 755, 756, 758, 760, 762, 763, 764, 765, 766, 768, 770
43663	jimmy1@adventure-works.com	760
43664	sandeep2@adventure-works.com	714, 716, 771, 772, 773, 775, 777, 778
43665	richard1@adventure-works.com	707, 709, 711, 712, 715, 773, 775, 776, 777, 778
43666	abraham0@adventure-works.com	732, 753, 756, 764, 766, 768
43667	scott7@adventure-works.com	710, 773, 775, 778
*/
DROP TABLE #temp;



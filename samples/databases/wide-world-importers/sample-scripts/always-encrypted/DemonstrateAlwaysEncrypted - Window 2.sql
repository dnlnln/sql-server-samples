-- Always Encrypted Demo - Window 2

-- note this demo is continued from the first demo window

-- 4b. Right-click in this window and choose Connection, then Change Connection. 
-- 4c. In the connection dialog, click Options.
-- 4d. Type WideWorldImporters for the database name.
-- 4e. Click on Additional Connection Parameters and enter: Column Encryption Setting=enabled
-- 4f. Click Connect

-- Note that when acting as a client with access to the certificate, we
-- can see the data. Remember that this can only work because
-- the client happens to be the same machine as the server in our 
-- case. 

SELECT * FROM Purchasing.Supplier_PrivateDetails ORDER BY SupplierID;
GO

-- Continue on the first window.

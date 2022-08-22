IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'People')
BEGIN
    CREATE TABLE dbo.People (id int IDENTITY(1,1), firstname varchar(50));

    INSERT INTO dbo.People (firstname) VALUES ('Carol');
    INSERT INTO dbo.People (firstname) VALUES ('Grace');
    INSERT INTO dbo.People (firstname) VALUES ('Katherine');
    INSERT INTO dbo.People (firstname) VALUES ('Ada');
    INSERT INTO dbo.People (firstname) VALUES ('Carol');
END

IF OBJECT_ID ( 'dbo.getPersonById', 'P' ) IS NOT NULL
    DROP PROCEDURE dbo.getPersonById;
GO

CREATE PROCEDURE dbo.getPersonById
    @id int
AS 
    SET NOCOUNT ON;
    SELECT id,firstname FROM dbo.People WHERE id = @id;


IF OBJECT_ID ( 'dbo.getPeople', 'P' ) IS NOT NULL
    DROP PROCEDURE dbo.getPeople;
GO

CREATE PROCEDURE dbo.getPeople
AS 
    SET NOCOUNT ON;
    SELECT id,firstname FROM dbo.People ORDER BY firstname;
GO
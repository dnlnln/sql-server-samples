DROP TABLE IF EXISTS Todo
DROP PROCEDURE IF EXISTS createTodo
DROP PROCEDURE IF EXISTS updateTodo
GO

CREATE TABLE Todo (
	Id int IDENTITY PRIMARY KEY,
	Title nvarchar(30) NOT NULL,
	Description nvarchar(4000),
	Completed bit,
	TargetDate datetime2
)
GO

INSERT INTO Todo (Title, Description, Completed, TargetDate)
VALUES
('Install SQL Server 2016','Install RTM version of SQL Server 2016', 0, '2016-06-01'),
('Get new samples','Go to github and download new samples', 0, '2016-06-02'),
('Try new samples','Install new Management Studio to try samples', 0, '2016-06-02')

GO

create procedure dbo.createTodo(@todo nvarchar(max))
as begin
	insert into Todo
	select *
	from OPENJSON(@todo) 
			WITH (	Title nvarchar(30), Description nvarchar(4000),
					Completed bit, TargetDate datetime2)
end
GO

create procedure updateTodo(@id int, @todo nvarchar(max))
as begin
	update Todo
    set Title = json.Title, Description = json.Description,
        Completed = json.Completed, TargetDate = json.TargetDate
    from OPENJSON( @todo )
			WITH(   Title nvarchar(30), Description nvarchar(4000),
					Completed bit, TargetDate datetime2) AS json
    where Id = @id
end

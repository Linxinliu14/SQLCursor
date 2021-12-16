USE Graph;


Declare @empid int;
Declare @department Varchar(20);
Declare @emplname Varchar(20);
Declare @level int;
Declare @mangid int;
Declare @mangname Varchar(20);

create table #temp 
(EmpID	int,
EmpLName	Varchar(20),
Department	Varchar(20),
[Level] int,
MgrID	int, 
MgrLName Varchar(20))

Declare graph_cursor Cursor For
	SELECT EmployeeID AS EmpID
	  ,LastName AS EmpLName
	  ,Department
		from OrgHierarchy 
		order by Department ASC, ReportsTo ASC;

set @empid=(select o.EmployeeID from OrgHierarchy o
where o.ReportsTo=Null);

Open graph_cursor;
Fetch next from graph_cursor into @empid, @emplname,@department;

set @level=0;


while @@FETCH_STATUS = 0
Begin

select @mangid=e.ReportsTo, @mangname=( select LastName from OrgHierarchy where EmployeeID=e.ReportsTo ) from OrgHierarchy e 
where e.EmployeeID=@empid

Insert into #temp
values(@empid, @emplname,@department,@level,@mangid,@mangname);

set @level=@level+1;

Fetch next from graph_cursor into @empid, @emplname,@department;

End;
Close graph_cursor;
Deallocate graph_cursor;

Select * from #temp ;

Drop table #temp;


			  
/*Result:
2	Fuller	NULL	0	NULL	NULL
5	Buchanan	Finance	1	2	Fuller
6	Suyama	Finance	2	5	Buchanan
7	King	Finance	3	5	Buchanan
12	Chang	Finance	4	7	King
13	Morales	Finance	5	12	Chang
14	Ng	Finance	6	12	Chang
16	Lee	Finance	7	14	Ng
17	Spencer	Finance	8	16	Lee
20	White	Finance	9	16	Lee
22	Norman	Finance	10	16	Lee
19	Smith	Finance	11	17	Spencer
3	Leverling	IT	12	2	Fuller
4	Peacock	IT	13	3	Leverling
1	Davolio	IT	14	3	Leverling
8	Callahan	IT	15	4	Peacock
9	Dodsworth	IT	16	4	Peacock
10	Robinson	IT	17	8	Callahan
11	Smith	IT	18	8	Callahan
15	Black	IT	19	11	Smith
21	Thompson	IT	20	11	Smith
*/
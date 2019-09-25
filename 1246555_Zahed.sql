

                                                      
                 --                                               - IDB-BISEW
                                                           --   Subject : C#
                                                        --Project  Name : NGO Structure
                                                                 --Name : MD. Zahedul Islam
                 --                                                 ID  : 1246555
                                                              --  Round : 39
                 --                                       Supervised By : MD. FOYSAL WAHID
															
                                                        


--====================================================================================================================================

USE master
GO

IF DB_ID('ProjectNgo') IS NOT NULL
    DROP DATABASE ProjectNgo
GO

create database ProjectNgo
GO

Alter database ProjectNgo modify file(name=N'ProjectNgo',size=10MB,maxsize=unlimited,filegrowth=1024KB)
go

alter database ProjectNgo modify file(name=N'ProjectNgo_log',size=9MB,maxsize=100MB,filegrowth=10%)
go

use ProjectNgo
go

create schema zahed
go

create table zahed.Funding
(
DonerID int primary key identity,
DonerName varchar(30),
YearlyDonation money,
MonthlyDonation money,
DonationAmount money,
date as getdate()
)
go

create table zahed.Authority
(
AuthorityID int primary key identity,
Name varchar(20),
BirthDay date,
Age as datediff(year,BirthDay,getdate()),
CellPhone Char(15),
termination date 
)
go

insert into zahed.Authority values('Bayzid','10/15/1993',019118384,''),
								  ('Akib','04/04/1995',016718384,''),
								  ('Faruk','04/14/1997',018118384,''),
								  ('Zahed','10/15/1989',01811367595,'')
go

--truncate Table zahed.Authority
--go

update zahed.Authority set Name='akib'
where AuthorityID=1
go

select * from zahed.Authority
go

create table zahed.Branch
(
BranchID int primary key identity,
BranchName varchar(30)
)
go

insert into zahed.Branch values('Crb'),('SholoShor'),('DC Hill'),('Agerabed'),('Amen Bazer'),('Potiya')
go

create table zahed.Member
(
MemberID int primary key identity,
MemberName  varchar(30) not null,
BranchID int foreign key references zahed.Branch(BranchID),
BirthDay date,
Age as datediff(year,BirthDay,getdate()),
CellPhone Char(15) check (CellPhone like '017%'),
termination date,
)
go

insert into zahed.Member values('Nishan',1,'10/10/1995','01711367595','')
go

create table zahed.Student
(
StudentID int primary key identity,                     
StudentName varchar(30) not null,
BranchID int foreign key references zahed.Branch(BranchID),
Class varchar(20),
Birthday date,
Age as datediff(year,BirthDay,getdate()),
)
go
insert into zahed.Student values('Rony',1,'Six','10/10/2010'),
								('Sakib',2,'Eight','10/10/2007'),
								('Anik',3,'Eight','10/10/2005')
go

--truncate table zahed.Student
--go

create table zahed.Expendable
(
ExpendableID int primary key identity,
StudentID int foreign key references zahed.Student(StudentID),
Books money,
sancks Money,
Treatment money,
Dr_Fee money,
SchoolFee money,
SchoolDress money,
Stipends money,
TotalCost as(Books+sancks+Treatment+Dr_Fee+SchoolFee+SchoolDress+Stipends)
)
go
insert into zahed.Expendable values(1,100,20,160,40,120,1200,1800)								
go

select* from zahed.Authority
select* from zahed.Branch
select* from zahed.Expendable
select* from zahed.Funding
select* from zahed.Member
select* from zahed.Student
go

----------------------Store proc
create proc Sp_AllInOne
(

@branchid int,
@branchname varchar(30),

@memberid int,
@membername  varchar(30),
@birthday date,
@cellphonee Char(15),
@termination date,

@studentid int,
@studentname varchar(30),
@class varchar(20),


@tablename varchar(20),
@operation varchar(15)
)
as
begin
    begin try
        begin tran
			if(@tablename='Branch' and @operation='Insert')
			Begin
				insert into zahed.Branch(BranchName) values(@branchname)
			End
			else if(@tablename='Branch' and @operation='update')
			Begin
				update zahed.Branch set  BranchName=@branchname where BranchID=@branchid
			End
			else if(@tablename='Branch' and @operation='delete')
			Begin
				delete from zahed.Branch where BranchID=@branchid
			End
			-------------------------------------------------
			else if(@tablename='Member' and @operation='Insert')
			Begin
				insert into zahed.Member(MemberName,BranchID,BirthDay,CellPhone,termination) values(@membername,@branchid,@birthday,@cellphonee,@termination)
			End
			else if(@tablename='Member' and @operation='Update')
			Begin
				update zahed.Member set MemberName=@membername,BranchID=@branchid,BirthDay=@birthday,CellPhone=@cellphonee,termination= @termination where  MemberID=@memberid
			End
			else if(@tablename='member' and @operation='Delete')
			Begin
				delete from zahed.Member where MemberID=@memberid
			End
			-----------------------------------------------------
			else if(@tablename='Student' and @operation='Insert')
			Begin
				insert into zahed.Student(StudentName,BranchID,Class,Birthday) values (@studentname,@branchid,@class,@birthday)
			End
			else if(@tablename='Student' and @operation='Updaet')
			Begin
				update zahed.Student set StudentName=@studentname,BranchID=@branchid,Class=@class,Birthday=@birthday where StudentID=@studentid
			End
			else if(@tablename='Student' and @operation='Delete')
			Begin
			--exists (StudentID>0)
				delete from zahed.Student where StudentID=@studentid
			End         
        commit tran
    end try

    begin catch
        rollback tran
        print 'Some thing gone wrong  !!!!!'
    end catch
end
go

exec Sp_AllInOne 1,'Crb',1,'Zahed','10/15/1993','01711367595',null,1,'Suman','One','Member','Insert'
go

select* from zahed.Funding
select* from zahed.Authority
select* from zahed.Branch
select* from zahed.Member
select* from zahed.Student
select* from zahed. Expendable
go





---view&join
create view vw_AuthMem
with SchemaBinding
as
select  a.AuthorityID,a.Name,a.CellPhone,m.MemberID,m.MemberName
from zahed.Authority a
join zahed.Member m
on a.Age=m.Age
where m.MemberID in (select MemberID from zahed.Member)
go

--union all operator
select MemberID
from zahed.Member
union all
select StudentID
from zahed.Student
order by MemberID
go


-----=========all aggrigate function
select MemberName,count(MemberID)
from zahed.Member
where MemberID>0
group by MemberName
having count(MemberID)>1
order by MemberName
go


----EXCEPT-----
Select BranchID From zahed.Branch
EXCEPT
Select MemberID From zahed.Member
Go

----ANY----
Select BranchName
From zahed.Branch
Where BranchID=ANY(Select StudentID from zahed.Student Where StudentID=1)
Go
----SOME----
if 1<SOME (SELECT BranchID FROM zahed.Branch)
PRINT'TRUE'
ELSE 
PRINT'FALSE!!!'
GO


---Between @ AND
SELECT * FROM zahed.Funding
WHERE DonerID BETWEEN '1' AND '2'
Go

-------Not Between
SELECT * FROM zahed.Funding
WHERE DonerID not BETWEEN '1' AND '2'
Go

---------Round
SELECT ROUND(TotalCost,0) AS [Total Cost]
FROM zahed.Expendable
Go
--------injection
SELECT * FROM zahed.Member WHERE MemberID = 1 or 1=1
go
---------Date format
SELECT FORMAT(min(2),'12-12-2018') AS issuedDate
FROM zahed.Member
Go


----Where ,And@ Or
Select *
From zahed.Member
Where MemberID = 1
AND MemberName='zahed'
or MemberName='faruk'
Go

-----CTE
with StudentCTE
as
(
select StudentID,StudentName from zahed.Student
)

select*from StudentCTE
go

-----SEQUENCE
CREATE SEQUENCE sq_Fundunf
as bigint
start with 1
increment by 1
minvalue 0
maxvalue 100
no cycle
cache 10
go





----=====with rollup
select class,sum (BranchID) 
from zahed.Student 
group by Class with rollup
go

----=====with cube
select class,sum (BranchID)
from zahed.Student
group by class with cube
go

--grouping sets
select class,StudentID
from zahed.Student
group by grouping sets((class),(StudentID))
go

------------create Function
create function fn_donaer
(
@yearlyDonation money,
@monthlyDonation money
)
returns int
as
begin
    declare @donationAmount money
    set @donationAmount=@yearlyDonation+@monthlyDonation
    return @donationAmount
end
go


create proc sp_Funding
(
@donerName varchar(30),
@yearlyDonation money,
@monthlyDonation money
)
as
Begin
insert into zahed.Funding(DonerName,YearlyDonation,MonthlyDonation,DonationAmount)
values(@donerName,@yearlyDonation,@monthlyDonation,dbo.fn_donaer(@yearlyDonation,@monthlyDonation))
End
go

Exec dbo.sp_Funding Zahid, 200, 50
GO


select* from zahed.Funding
go



-------------------trigger
create table zahed.Authority_audit
(
AuthorityID int,
Name varchar(20),
BirthDay date,
Age as datediff(year,BirthDay,getdate()),
CellPhone Char(15),
termination date,
Audit_Action varchar(100),
Audit_Timestamp as getdate()
)
go

create index IX_Aurhoraudit
on zahed.Authority_audit(AuthorityID)
go




--=== After Trigger (insert) ===========
create trigger tr_Athority on zahed.Authority
for insert , update
as
declare @authorityID int,
        @name varchar(20),
        @birthDay date,
        @age date,
        @cellPhone Char(15),
        @termination date,
        @audit_Action varchar(100)
select @authorityID=i.AuthorityID from inserted i
select @name=i.Name  from inserted i
select @birthDay=i.BirthDay from inserted i
select @cellPhone=i.CellPhone from inserted i
select @termination=i.termination from inserted i
set @audit_Action='Inserted Record ---  Trigger Fired !!!'
insert into zahed.Authority_audit(Name,BirthDay,CellPhone,termination,Audit_Action) values(@name,@birthDay,@cellPhone,@termination,@audit_Action)
print 'After Update Trigger Fired Successfully !!!'
go



--=== After Trigger (delete) ===========
create trigger tr_Athoritydelete on zahed.Authority
for delete
as
declare @authorityID int,
        @name varchar(20),
        @birthDay date,
        @age date,
        @cellPhone Char(15),
        @termination date,
        @audit_Action varchar(100)
select @authorityID=i.AuthorityID from deleted i
select @name=i.Name  from inserted i
select @birthDay=i.BirthDay from deleted i
select @cellPhone=i.CellPhone from deleted i
select @termination=i.termination from deleted i
set @audit_Action='Inserted Record --- After delete Trigger Fired !!!'

insert into zahed.Authority_audit(Name,BirthDay,CellPhone,termination,Audit_Action) values(@name,@birthDay,@cellPhone,@termination,@audit_Action)
print 'After delete Trigger Fired Successfully !!!'
go


insert into zahed.Authority values('Zahed','04/04/1993',019118384,'')
go

delete zahed.Authority where Name='Zahed'
go

update zahed.Authority set Name='akib'
where AuthorityID=1
go

select* from zahed.Funding
select* from zahed.Authority
select*from zahed.Authority_audit
select* from zahed.Branch
select* from zahed.Member
select* from zahed.Student
select* from zahed. Expendable
go


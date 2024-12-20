-----------------------------------------------------------------------------------------------------------------------

-- <*> Welcome to my work where I create the Travel database and meet the data requested by the necessary department.
-- <*> In this study, you will find my reviews within the tables I created by creating my tables with “create table”. 
-- <*> Here I effectively used “JOIN” functions, “CASE WHEN” expressions, “PRIMARY KEY” and “FOREIGN KEY” creation and 
-- filtering operations and many more. We can start the review. 

-- <!> Note: Visualization can optionally be done in Excel and Power BI. I will prefer Power BI.

-----------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------------
-- <*> We are asked to create tables and ERD. 
-- <*> You can examine the ERD by right-clicking on the database and clicking on the “ERD for databases” tab.
-----------------------------------------------------------------------------------------------------------------------



create table booking
(
	id integer primary key,
	contactID integer,
	contactEmail varchar,
	company varchar,
	memberSales varchar,
	userID varchar,
	userRegisterDate timestamp,
	environemnt varchar,
	bookindDate timestamp
)
;
select * from booking
order by contactid
;
alter table booking
rename column bookindDate to bookingDate
;
truncate table booking

;

create table passenger
(
	id integer primary key,
	bookingID integer,
	gender varchar,
	name varchar,
	dateOfBirth timestamp
)
;
select * from passenger
order by id
;
alter table passenger
alter column dateofbirth type date

;

create table payment
(
	id integer primary key,
	bookingID integer,
	amount integer,
	cardType varchar,
	paymentStatus varchar,
	cardNumber varchar,
	paymentDate timestamp
)
;
select * from payment
order by bookingid
;
alter table passenger
add constraint fk_booking
foreign key (bookingid) references booking(id)
;
alter table payment
add constraint fk_booking
foreign key (bookingid) references booking(id)
;
select * from booking
;
select * from passenger
;
select * from payment
;


-----------------------------------------------------------------------------------------------------------------------
-- <*> Suppose the relevant department wants total number of sales, amounts and average ticket prices on customer basis.
-----------------------------------------------------------------------------------------------------------------------



select b.contactid,
	   count(py.id),
	   sum(py.amount),
	   round(avg(py.amount),2)
from booking as b
left join payment as py
on b.id=py.bookingid
group by 1
order by 1
;


-----------------------------------------------------------------------------------------------------------------------
-- <*> The relevant department wants to conduct a monthly review in 2020. 
-- <*> In this context, it asked me to calculate the total number of passengers and baskets by environment.
-----------------------------------------------------------------------------------------------------------------------



select 
	distinct(b.environment),
	count(b.id) as booking_id,
	count(p.id) as passenger_id
from booking as b
inner join passenger as p
on b.id=p.bookingid
where b.bookingdate>='2020-01-01'  and b.bookingdate<'2021-01-01'
group by 1
;



-----------------------------------------------------------------------------------------------------------------------
-- <*> If I am asked to calculate bank success rates for moves to be made:
-- <*> (I will present it in two different ways, based on card type and total.)
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- <*> Card Type Based:
-----------------------------------------------------------------------------------------------------------------------
select 
	distinct cardtype,
	'% '||round((count(case when paymentstatus = 'ÇekimBaşarılı' then 1 end)::decimal/count(paymentstatus))*100,2) as BankaBaşarıOranı
from payment
group by 1


-----------------------------------------------------------------------------------------------------------------------
-- <*> Total Succes Rate:
-----------------------------------------------------------------------------------------------------------------------
SELECT 
    (COUNT(CASE WHEN paymentstatus = 'ÇekimBaşarılı' THEN 1 END)::decimal / COUNT(*)) AS ratio
FROM 
    payment
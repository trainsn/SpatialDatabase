create extension postgis;

drop table if exists Sales;
create table Sales
(
  name varchar(255),
  discount float,
  month varchar(10),
  price float
);

select * from Sales;
delete from Sales;

copy Sales(name,discount,month,price) from 'e:\\SaleData.txt' delimiter  '#';


drop table if exists NameMonth;
drop table if exists NamePrice;
create table NamePrice
(
  name varchar(255) primary key,
  price float
);

drop table if exists MonthDis;
create table MonthDis
(
  discount float,
  month varchar(10) primary key
);

create table NameMonth
(
  name varchar(255),
  month varchar(10),
  primary key (name,month),
  foreign key (name) references NamePrice,
  foreign key (month) references MonthDis
);

insert into nameprice
select distinct name,price
from sales;

insert into monthdis
select distinct discount,month
from sales;

insert into namemonth
select distinct name,month
from sales;

select * from namemonth natural join nameprice natural join monthdis;
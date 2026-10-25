create database retail_analytics;
use retail_analytics;

select * from customers; -- customerid is messed up
select * from products; -- productid is messed
select * from sales; -- transaction id is messed

alter table sales
rename column ï»¿TransactionID to TransactionID;
alter table products
rename column ï»¿ProductID to ProductID;
alter table customers
rename column ï»¿CustomerID to CustomerID;

-- Problem 1 - removing duplicates from sales
select TransactionID,
count(*) 
from sales
group by 1 having count(*)>1;

create table sales_unique
as select distinct * from sales;

drop table sales;

alter table sales_unique rename to sales;

-- problem 2 - identifying discrepancies in price
select * from products;
desc products;
desc sales;
-- to identify the discrepancies, we first join the two tables
select p.productid,s.transactionid,
s.price as transactionprice,
p.price as inventoryprice
from sales s 
join products p on s.productid=p.productid
where p.price!=s.price;
-- update the discrepencies
set sql_safe_updates=0;
update sales s 
set price=(select p.price from products p 
where s.productid=p.productid)
where s.productid in (
select productid from products p 
where p.price<>s.price);

-- Problem 3 - identify empty values and replace then with null
select * from customers; -- only location as empty values

select count(*) 
from customers where location="";

update customers
set location = "Unknown"
where location="";

-- Problem 4 -- clean the date column in sales table
select * from sales;
create table sales_date_fixed as 
select * from sales;

update sales_date_fixed
set Transactiondate = str_to_date(transactiondate,'%Y/%m/%d'); -- string to date format
alter table sales_date_fixed
modify transactiondate date; -- changing the datatype

alter table sales_date_fixed
add column transactiondate_updated date;
update sales_date_fixed
set transactiondate_updated=transactiondate;
select * from sales_date_fixed;
drop table sales;
create table sales as
select * from sales_date_fixed;
desc sales_date_fixed;
drop table sales_date_fixed;
select * from sales;

-- problem 5 -summarize the total sales and quantities
select * from products;
select * from sales;
select productid,
sum(quantitypurchased) as unitsSold,
round(sum(price*quantitypurchased),2) as totalSales
from sales
group by 1
order by 3 desc;

-- problem 6 - to count the no. of customers per transaction - understanding purchase frequency
select customerid,
count(distinct transactionid) as noOfTransactions
from sales 
group by 1 
order by 2 desc;

-- problem 7 - analyzing category performance
select * from customers;
select p.category,
sum(s.quantitypurchased) as totalUnitsSold,
sum(p.price*s.quantitypurchased) as totalSales
from sales s 
join products p 
on s.productid=p.productid
group by 1
order by 3 desc;

-- problem 8 - top 10 products with highest sales 
select productid,round(sum(price*quantitypurchased),2) as totalRevenue
from sales
group by 1
order by 2 desc
limit 10;

-- problem 9 least selling products
select ProductID,
sum(quantitypurchased) as TotalUnitsSold
from sales
group by ProductID
having TotalUnitsSold>0
order by TotalUnitsSold asc
limit 10;

-- problem 10 - identify sales trend
select 
cast(transactiondate as date) as dateTrans,
count(distinct transactionid) as transaction_count,
sum(quantitypurchased) as TotalUnitsSold,
round(sum(price*quantitypurchased)) as TotalSales
from sales 
group by 1
order by 1 desc;

-- problem 11 - month on month sales trend
with monthly_sales as (
select month(transactiondate) as month,
round(sum(quantitypurchased*price),2) as totalsales
from sales 
group by 1
)
select month,totalsales,
lag(totalsales) over(order by month) as previous_monthsales,
round((totalsales-lag(totalsales) over(order by month))/(lag(totalsales) over(order by month))*100,2) as  mom_growth
from monthly_sales
order by month;

-- problem 12 - identifying high value customers
select customerid,
count(distinct transactionid ) as NoOfTransactions,
sum(quantitypurchased*price) as TotalSpent
from sales
group by customerid
having NoOfTransactions>10
and TotalSpent >1000
order by TotalSpent desc;

-- Problem 13
select customerid,
count(distinct transactionid ) as NoOfTransactions,
sum(quantitypurchased*price) as TotalSpent
from sales
group by customerid
having NoOfTransactions<=2
order by NoOfTransactions,TotalSpent desc;

-- problem 14 - repeat customers
select customerid,productid,
count(*) as timesPurchased
from sales
group by 1,2
having timesPurchased>1
order by timesPurchased desc;

-- problem 15 - duration between first and last purchase
select customerid,
min(transactiondate) as FirstPurchase,
max(transactiondate) as LastPurchase,
datediff(max(transactiondate),min(transactiondate)) as DaysBetweenPurchases
from sales
group by customerid
having DaysBetweenPurchases>0
order by 4 desc;

-- Problem 16 - customer segmentation
create table customer_segment as
with cust_base as(
select c.customerid,
sum(s.quantitypurchased) total_qty
from sales s 
left join customers c 
on s.customerid=c.customerid
group by 1
)
select customerid,
case when total_qty between 1 and 10 then 'Low'
when total_qty between 11 and 30 then 'Med'
when total_qty >30 then 'High'
else 'None'
end as CustomerSegment
from cust_base;
select CustomerSegment,count(*) from customer_segment 
group by 1;
    
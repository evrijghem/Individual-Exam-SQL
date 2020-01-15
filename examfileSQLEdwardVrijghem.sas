libname chinook "C:\Users\evrijghem\Documents\GitHub\BRT\Extra_dataset"; run;
/*Exam file Edward Vrijghem 18/10/2019*/
/*question 5: I tried two solutions, one which is not correct but worked, the other using subqueries but didn't work. 

first determining the month with the most sales: */
proc sql;
select month(datepart(i.invoicedate)) as month, sum(i.total) as sales2011
from chinook.invoices as i
where year(datepart(i.invoicedate))= 2011
group by 1;
quit;
run;

/*Solution 1 is using just month "4" found by reading the output of the previous query */
proc sql;
select e.firstname, e.lastname, sum(i.total) as total
from chinook.employees as e, chinook.customers as c, chinook.invoices as i 
where e.employeeID=c.supportrepID and c.customerID=i.customerID and year(datepart(i.invoicedate)) = 2011 and month(datepart(i.invoicedate)) = 4
group by e.firstname, e.lastname;
quit;
run;

/* Solution 2 using subquerys, no results */
proc sql;
select e.firstname, e.lastname, sum(i.total) as total
from chinook.employees as e, chinook.customers as c, chinook.invoices as i 
where e.employeeID=c.supportrepID and c.customerID=i.customerID and year(datepart(i.invoicedate)) = 2011 
and month(datepart(i.invoicedate)) = 
	(select month(datepart(i.invoicedate)) as month
	from chinook.invoices as i
	where year(datepart(i.invoicedate))= 2011
	/*group by i.customerid*/
	having i.total >= (select month(datepart(i.invoicedate)) as month
				from chinook.invoices as i
				where year(datepart(i.invoicedate))= 2011
				/*group by i.customerid*/))
group by e.firstname, e.lastname;
quit;
run;
/* KLAD: proc sql;
select month(datepart(i.invoicedate)) as month
	from chinook.invoices as i
	where year(datepart(i.invoicedate))= 2011
	group by i.customerid
	having i.total >= (select i.total as total
				from chinook.invoices as i
				where year(datepart(i.invoicedate))= 2011
				group by i.customerid);
				quit;
				run;

 proc sql;
select month(datepart(i.invoicedate)) as month, sum(i.total) as sum
from chinook.invoices as i
where year(datepart(i.invoicedate))= 2011
group by 1 
having sum >= (select sum(i.total) as sum
from chinook.invoices as i
where year(datepart(i.invoicedate))= 2011)

;
quit;
run; */

/*Question 6*/

proc sql;
select distinct a.albumID as AlbumID, ((sum(t.milliseconds)/1000)/60) as DurationInMinutes, g.Name as Genre
from chinook.genres as g, chinook.tracks as t, chinook.albums as a
where g.genreID=t.genreID and t.AlbumID = a.albumID
group by 1,3
having count(g.genreID) = 1;
quit;
run;

/* Question 7*/
proc sql;
select t.trackID as trackID, count(distinct inv.customerID) as NumberOfCustomers
from chinook.tracks as t, chinook.invoice_items as i, chinook.invoices as inv
where t.trackid=i.trackid and i.invoiceid=inv.invoiceid
group by t.trackID;
quit;
run;

/*Question 8*/

proc sql;
select c.country, count(distinct c.customerID) as NumberOfCustomers
from chinook.customers as c
where c.Lastname like 'S%'
group by c.country;
quit;
run;

/*Question 9*, addtional comment: I know :(case when country ='US' then "US" else "Non US" end as country) is not 
the most efficient but i wanted to show that I know how it works
(eihterway, this is probably not the most efficient solution)*/ 

 
Proc sql;
select c.customerID, case when c.country ='USA' then "USA" else "Non USA" end as country, sum(i.total) as sum
from chinook.customers as c, chinook.invoices as i
where c.customerid=i.customerid and c.country = "USA"
group by 1
having sum(total)>(select 0.8*max(sales) From
(select sum(total) as sales 
from chinook.customers as c, chinook.invoices as i
where c.customerid=i.customerid and c.country = "USA"
group by c.customerid))
UNION 
select c.customerID, case when c.country ='USA' then "USA" else "Non USA" end as country, sum(i.total) as sum
from chinook.customers as c, chinook.invoices as i
where c.customerid=i.customerid and c.country <> "USA"
group by 1
having sum(total)>(select 0.8*max(sales) From
(select sum(total) as sales 
from chinook.customers as c, chinook.invoices as i
where c.customerid=i.customerid and c.country <> "USA"
group by c.customerid));
quit;
run;


/*Question 10 part 1, selecting the cities of managers*/

proc sql;
select distinct e.city
from chinook.employees as e
where lowcase(e.title) contains 'manager';
quit;
run;  


/*10 full solution*/

Proc sql;
select c.firstname as Firstname, c.lastname as name, 'customer' as title
from chinook.customers as c
where c.city IN 
(select distinct e.city
from chinook.employees as e
where (lowcase(e.title) contains 'manager'))
UNION
select e.firstname as firstname, e.lastname as name, 'employee' as title
from chinook.employees as e
where e.city IN 
(select distinct e.city
from chinook.employees
where (lowcase(e.title) contains 'manager'))
;
quit;
run;





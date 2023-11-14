****************************************************************;
* SAS COMPUTE SERVER - DATABASE PROCESSING                     *;
****************************************************************;

*******************************************************************;
* 1. Connect to Oracle using the traditional SAS/ACCESS Interface *;
*******************************************************************;
libname or_db oracle path="//server.demo.sas.com:1521/ORCL"
                     user="STUDENT" 
                     password="Metadata0"
                     schema="STUDENT";


**************************************************;
* 2. Show SAS Compute server LIBNAME engine log  *;
**************************************************;
options sastrace=',,,d' sastraceloc=saslog nostsuffix sql_ip_trace=(note,source);


****************************************************************;
* 3. IMPLICIT PASS THROUGH ON THE SAS COMPUTE SERVER           *;
****************************************************************;
* SAS will attempt to convert PROC SQL into native database SQL*;
* wherever possible. If it can't convert the SQL it will bring *;
* the data to the SAS Compute Server for processing.           *;
****************************************************************;
* NOTE: Implicit pass-through features vary by database.       *;
****************************************************************; 

****************************************************************;
* a. View available database tables in the OR_DB SAS library   *;
****************************************************************;
proc contents data=or_db._all_ nods;
run;
            

*******************************************; 
* b. Preview the LOANS_RAW database table *;
*******************************************; 
proc sql;
select *
   from or_db.loans_raw(obs=10);
quit;


*****************************************************************; 
* c. Count the number of rows and total loan amount by Category *;
*****************************************************************; 

* Use SQL implicit pass-through. Notice that the SAS SQL is converted into Oracle SQL. *;
proc sql;
select Category, 
       count(*) as TotalLoansByCategory format=comma16.,
       sum(Amount) as TotalAmount format=dollar20.2
    from or_db.loans_raw
    group by Category
    order by Category;
quit;

* Disable implicit pass-through. Notice that SAS will bring back all rows and only the necessary 
* columns to the SAS Compute Server for processing. *;
proc sql NOIPASSTHRU;
select Category, 
       count(*) as TotalLoansByCategory format=comma16.,
       sum(Amount) as TotalAmount format=dollar20.2
    from or_db.loans_raw
    group by Category
    order by Category;
quit;


*************************************************************************; 
* d. Count the number of cancelled loans by Year that begin with 'Bad'  *;
*************************************************************************; 

******************************;
* Use the SAS SCAN function  *;
******************************;
* Notice that SAS can't convert the SCAN function to native Oracle SQL *;
* and will bring the data to the SAS Compute server for processing.    *;
proc sql;
select Year, 
       count(*) as TotalCancelled_BAD format=comma16.
    from or_db.loans_raw
    where scan(CancelledReason,1) = 'Bad'     /* use the SAS SCAN function */
    group by Year
    order by Year desc;
quit;

******************************;
* Use the ANSI LIKE operator *;
******************************; 
* Notice that this query is converted to native Oracle SQL for in-database processing. *;
proc sql;
select Year, 
       count(*) as TotalCancelled_BAD format=comma16.
    from or_db.loans_raw
    where CancelledReason like 'Bad %'       /* Use ANSI SQL syntax */
    group by Year
    order by Year desc;
quit;


******************************************************************************************************;
* DOCUMENTATION                                                                                      *;
******************************************************************************************************;
* Passing SAS Functions to Oracle                                                                    *;
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/acreldb/p0f64yzzxbsg8un1uwgstc6fivjd.htm *;
******************************************************************************************************;


**************************************************************************************************; 
* e. Use SAS date functions in a query to obtain the Year from the LastPurchase column to count  *;
*    the last time a credit card was used by year.                                               *;
* Example: LastPurchase: 01JAN1960:06:23:05.000000                                               *;
**************************************************************************************************; 
proc sql;
select year(datepart(LastPurchase)) as LastPurchaseYear,
       count(*) as Total format=comma16.,
       count(*)/(select count(*) 
                   from or_db.loans_raw 
                   where Category = 'Credit Card') as LastPurchasePct format=percent7.1
   from or_db.loans_raw
   where Category = 'Credit Card'
   group by LastPurchaseYear
   order by Total desc;
quit;
* Enter execution time --->   *;


****************************************************************;
* 4. EXPLICIT PASS-THROUGH ON THE SAS COMPUTE SERVER           *;
****************************************************************;
* Use native Oracle SQL through PROC SQL                       *;
****************************************************************;  

*******************************************************************************************;  
* a. Rewrite the previous query to use native Oracle SQL to summarize the data and SAS to *;
*    format the results.                                                                  *;
*******************************************************************************************;  

proc sql;
/* Connect to the Oracle database */
connect using or_db;

/* Use SAS formats for the results from the Oracle query */
select LastPurchaseYear,
       Total format=comma16.,
       LastPurchasePct format=percent7.1
  from connection to or_db
     (
      select EXTRACT( YEAR FROM "LastPurchase") as 
                                                LastPurchaseYear,
             count(*) as Total,
             count(*)/(select count(*) 
                         from loans_raw 
                         where "Category" = 'Credit Card') as LastPurchasePct
        from loans_raw
        where "Category" = 'Credit Card'
        group by EXTRACT(YEAR FROM "LastPurchase")
        order by Total desc
     );

/* Disconnect from the Oracle database */
disconnect from or_db;
quit;


******************************************************************************************************;
* DOCUMENTATION                                                                                      *;
******************************************************************************************************;
* SAS/ACCESS® for Relational Databases: Reference                                                    *;
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/acreldb/titlepage.htm                    *;
******************************************************************************************************;  
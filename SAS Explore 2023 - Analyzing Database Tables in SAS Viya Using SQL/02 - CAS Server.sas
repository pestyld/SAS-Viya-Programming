****************************************************************;
* CAS SERVER - DATABASE PROCESSING                             *;
****************************************************************;

****************************************************;
* 1. Connect to the CAS server and create a caslib *;
****************************************************;
* Connect to CAS *;
cas conn;

* Create a caslib to the CAS server using a SAS Viya Data Connector *;
caslib ordb_cas datasource=(srctype="oracle",
                            user="STUDENT",
                            password="Metadata0",
                            path="//server.demo.sas.com:1521/ORCL",
                            schema="STUDENT");


****************************************************;
* 2. View files and tables in the ordb_cas caslib  *;
****************************************************;
proc casutil incaslib = 'ordb_cas';
   list files;     * View available database tables *;
   list tables;    * View available in-memory CAS tables *;
quit;


*******************************************************************;
* 3. IMPLICIT PASS THROUGH IN CAS USING SAS VIYA DATA CONNECTORS  *;
*******************************************************************;
* SAS will attempt to convert PROC SQL into native database SQL   *;
* wherever possible.                                              *;
*******************************************************************; 
* NOTE: Implicit pass through features are database specific.     *;
*******************************************************************; 
          
* Use SQL implicit pass through on a caslib on a database table that is not loaded into memory. *;
* Notice that the SQL is converted into Oracle SQL and processed in-database. *;
proc fedsql sessref=conn _method;
select Category, 
       count(*) as TotalLoansByCategory,
       sum(Amount) as TotalAmount
    from ordb_cas.loans_raw          /* <--- Reference the database table name */
    group by Category;
quit;


*******************************************************************;
* 4. EXPLICIT PASS THROUGH IN CAS USING SAS VIYA DATA CONNECTORS  *;
*******************************************************************;
* Use native Oracle SQL through a caslib                          *;
*******************************************************************;  

* Use native Oracle SQL to summarize the database table and then create a in-memory CAS table *;
proc fedsql sessref=conn _method;
create table ordb_cas.CCAccounts2022 as
  select * 
  from connection to ordb_cas
     (
      /* Send native Oracle query directly to the database for processing */
      select *
        from loans_raw
        where EXTRACT(YEAR FROM "LastPurchase") = 2022 and 
              "Category" = 'Credit Card'
     );
quit;


***************************;
* 5. Analyze a CAS table  *;
***************************;

* a. View information about the caslib and CAS table *;
proc casutil;
    list tables incaslib='ordb_cas';     * List available in-memory CAS tables *;
    contents casdata="CCAccounts2022" incaslib="ordb_cas"; * View CAS table metadata *;
quit;


* b. Run queries on the in-memory CAS table *;
proc fedsql sessref=conn _method;
select * 
    from ordb_cas.CCAccounts2022        /* <--- Reference the CAS table name */
    limit 10;

select LoanGrade, 
       count(*) as TotalLoansByCategory,
       sum(Amount) as TotalAmount
    from ordb_cas.CCAccounts2022        /* <--- Reference the CAS table name */
    group by LoanGrade
    order by LoanGrade;
quit;


*****************************************************************************************;
* c. Once a table is loaded into CAS you can also use CAS actions to process the table. *;
*    There are hundreds of available actions. For example, the summary CAS actions      *;
*    calculates descriptive statistics for a CAS table. Imagine writing this query!     *;
*****************************************************************************************;
proc cas;
   simple.summary /
     table = {name = 'CCAccounts2022',    /* <--- Reference the CAS table name */
              caslib = 'ordb_cas'};
quit;

***************************************************************************************;
* Benefits of CAS tables                                                              *;
***************************************************************************************;
* - CAS tables are distributed in memory for fast processing.                         *;
* - Ability to process the data using SQL and CAS actions (Python/R/SAS/CASL).        *;
* - You can use other SAS Viya applications on the CAS table for ML or Visualization. *; 
* - You can share in-memory CAS tables with other users.                              *;
***************************************************************************************;


***********************************;
* 6. Use PROC SQL on a CAS table. *;
***********************************;

* To use PROC SQL (or other SAS procedures) on a CAS table you must make a library reference to the caslib.  *;     
libname ordb_cas cas caslib='ordb_cas';

* Execute PROC SQL on a CAS table *;
proc sql;
select Category, 
       count(*) as TotalLoansByCategory,
       sum(Amount) as TotalAmount
    from ordb_cas.CCAccounts2022         /* <--- Reference the CAS table name */
    group by Category;
quit;
* Since PROC SQL does not run in CAS, CAS attempts to send the entire table over to the Compute server for processing. *;


******************************************************************************************************;
* DOCUMENTATION                                                                                      *;
******************************************************************************************************;
* SAS® Viya® Platform: FedSQL Programming for SAS® Cloud Analytic Services                           *;
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/casfedsql/titlepage.htm                  *;
******************************************************************************************************;  
* SAS® Viya® Platform: Data Connectors                                                               *;
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/casref/p0j09xx6p9ffven1x7z9cq8s1zaa.htm  *;
******************************************************************************************************;  
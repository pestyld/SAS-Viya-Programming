*****************;
* CAS Basics    *;
*****************;

************************************************;
* CHANGE THE PATH WHERE THE DATA IS LOCATED    *;
************************************************;
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let serverPath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,)); *<-----Change path and folder if necessary *;


* Connect to the CAS server *;
cas conn;


* Show all available caslibs (data sources) for the CAS server *;
* NOTE: Compare this list with available SAS Libraries using the navigation pane *;
caslib _all_ list;


* Create a caslib named ate_cas that uses the same location as the libname in program 01-processing in compute.sas *;
caslib ate_cas path="&serverPath";

* View all available caslibs in the CAS server *;
caslib _all_ list;

* Look at the files and tables in the ate_cas caslib in the CAS server *;
proc casutil;
    list files incaslib='ate_cas';
    list tables incaslib='ate_cas';
quit;


* Load data into CAS *;
proc casutil;
* Load the orders_demo.sas7bdat file into memory *;
    load casdata='orders_demo.sas7bdat' incaslib='ate_cas'
         casout='orders_demo' outcaslib='ate_cas' replace;

* Notice a CAS table is now available for processing *;
    list tables incaslib='ate_cas';
quit;


* (error) Try to use a CAS enabled proc to process the CAS table *;
proc print data=ate_cas.orders_demo(obs=10);
run;

************************************************************;
* Make a library reference to the caslib in the CAS server *;
************************************************************;
* NOTE: This is similar using a LIBNAME to connect to a database. CAS is external to compute, so you need an the CAS engine *;
* NOTE: Think of it this way. A database requires a database engine, the CAS server uses the CAS engine *;
libname ate_cas cas caslib='ate_cas';
* NOTE: After you execute the LIBNAME statement. View the available libraries using the navigation pane *;



*************************************************;
* Process the CAS table using CAS enabled procs *;
*************************************************;
* NOTE: The CAS engine converts the CAS enabled procs to CAS actions *;

*1*;
proc print data=ate_cas.orders_demo(obs=10);
run;
*2*;
proc means data=ate_cas.orders_demo;
run;

*********************************;
*3 PROC FREQ is not CAS enabled *;
*********************************;
* NOTE: If it's not cas enabled, the CAS engine does not know how to convert it to native CAS syntax.   *;
* NOTE: Since CAS doesn't know what to do, the data is sent back to the compute server for processing.  *;
* NOTE: This works similarly when using a database engine.                                              *;
proc freq data=ate_cas.orders_demo;
run;


* View what the procs were converted to through the CAS API when using the CAS engine.*;
cas conn listhistory _all_;


* Terminate the connection to CAS *;
cas conn terminate;
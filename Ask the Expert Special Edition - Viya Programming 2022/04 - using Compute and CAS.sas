************************************************************;
* USING SAS COMPUTE SERVER AND THE CAS SERVER AS A TEAM    *;
************************************************************;

************************************************;
* CHANGE THE PATH WHERE THE DATA IS LOCATED    *;
************************************************;
%let serverPath = /shared/home/Peter.Styliadis@sas.com/ate_path; *<-----Change path and folder name if necessary *;


************************************************************;
* 1. PREPARE AND SUMMARIZE THE DATA USING THE CAS SERVER   *;
************************************************************;
cas conn;
caslib ate_cas path="&serverPath";
libname ate_cas cas caslib='ate_cas';

* Load the orders_demo.sas7bdat file into memory in CAS *;
* NOTE: If you load a table into memory and promote it, it persists in memory between CAS sessions *;
proc casutil;
* Load the orders_demo.sas7bdat file into memory in CAS *;
    load casdata='orders_demo.sas7bdat' incaslib='ate_cas'
         casout='orders_demo' outcaslib='ate_cas';
quit;


* Execute the DATA step in CAS *;
data ate_cas.orders_demo_calc_columns;
    set ate_cas.orders_demo;
    Year = year(OrderDate);
    Month = Month(OrderDate);
    TotalCost = Quantity * Cost;
    TotalPrice = Quantity * Price;    
    Profit = TotalPrice - TotalCost;
    pctProfit = Profit / TotalCost;
    if Return='' then Return='No';
    format pctProfit percent7.2
           Price Cost TotalPrice TotalCost Profit dollar28.2;
run;


* Execute the summarization in CAS *;
proc mdsummary data=ate_cas.orders_demo_calc_columns;
    groupby Country Year;
    var TotalCost TotalPrice Profit;
    output out=ate_cas.orders_summary;
quit;




********************************************************************;
* 2. CREATE AN EXCEL REPORT USING THE COMPUTE SERVER               *;
*    WITH THE SUMMARIZED DATA IN CAS (75 row table)                *;
********************************************************************;
* Creat an Excel report and data visualization using the SAS compute server *;
* NOTE: The SGPLOT procedure is not CAS-enabled. The entire CAS table is sent to the compute server. *;
* NOTE: Since the CAS data is summarized, transferring the smaller data to the compute server is not an issue. *;

***************************;
* USING THE COMPUTE SEVER *;
***************************;
ods excel file="&serverPath/orders_summary.xlsx"
          style=excelilluminate
          options(sheet_interval='NONE' start_at='B2');

ods graphics / height=7in outputfmt=png;
proc sgplot data=ate_cas.orders_summary  
            noborder;
    vbar Country / 
        response=_Sum_ 
        group=Year
        groupdisplay=cluster;
    where _column_ = 'Profit';
    label _Sum_ = 'Total Profit';
    format _Sum_ dollar20.2;
run;
ods graphics / reset ;

proc print data=ate_cas.orders_summary label;
    var Country Year _Column_ _Sum_;
    where _Column_ = 'Profit';
    format _Sum_ dollar20.2;
    label _sum_ = "Total Profit";
run;

ods excel close;

cas conn terminate;

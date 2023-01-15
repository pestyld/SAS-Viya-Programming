******************************************************************************;
* PROCESSING DATA IN THE CAS SERVER USING SAS PROGRAMMING AND THE CAS ENGINE *;
******************************************************************************;


************************************************;
* CHANGE THE PATH WHERE THE DATA IS LOCATED    *;
************************************************;
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let serverPath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,)); *<-----Change path and folder if necessary *;


/* Start timer */
%let _timer_start = %sysfunc(datetime());  


* Connect to CAS *;
cas conn;

* Create a caslib to the data *;
caslib ate_cas path="&serverPath";

* Create a compute library reference to the CASLIB *;
libname ate_cas cas caslib='ate_cas';


* Load the files into memory *;
proc casutil;
    list files;

* Load the orders_demo.sas7bdat file into memory in CAS *;
    load casdata='orders_demo.sas7bdat' incaslib='ate_cas'
         casout='orders_demo' outcaslib='ate_cas';

* Load the orders_demo.sas7bdat file into memory in CAS *;
    load casdata='discount_lookup.sas7bdat' incaslib='ate_cas'
         casout='discount_lookup' outcaslib='ate_cas';
quit;


* Preview the data *;
proc print data=ate_cas.orders_demo(obs=10);
run;


* Explore continuous columns *;
proc means data=ate_cas.orders_demo;
run;


* DATA step executes directly in CAS *;
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


* Explore categorical columns *;
* NOTE: PROC FREQ IS NOT CAS ENABLED *;
* NOTE: The format statement does not work in FREQTAB *;
proc freqtab data=ate_cas.orders_demo_calc_columns;
    tables Product Country DiscountCode Return Year;
run;


* Preview the tables prior to the join *;
title "Preview the two tables to join";
proc print data=ate_cas.orders_demo_calc_columns(obs=10);
run;

proc print data=ate_cas.discount_lookup;
run;
title;


* Join with the Discount Lookup table *;
* PROC SQL is not CAS-enabled. Must use FedSQL*;
proc fedsql sessref=conn;
create table ate_cas.orders_demo_final as
    select f.*, 
           l.pct_discount * .01 as pctDiscount, 
           l.discount_description
        from ate_cas.orders_demo_calc_columns as f left join 
             ate_cas.discount_lookup as l
        on f.DiscountCode = l.discountCode;
quit;
proc print data=ate_cas.orders_demo_final(obs=10);
run;


* Find the total by each Country and Year *;

* PROC MEANS does some processing in CAS, then returns summarized data back to the Compute server for final processing*;
* This causes the MEANS procedure to be a bit more resource intensive and slower. *;
/* proc means data=ate_cas.orders_demo_final sum; */
/*     class Country Year; */
/*     var TotalCost TotalPrice Profit; */
/*     output out=ate_cas.orders_summary(where=(_Type_ = 3)) */
/*            sum(TotalCost)=TotalCostYearCountry */
/*            sum(TotalPrice)=TotalPriceYearCountry */
/*            sum(Profit)=TotalProfitYearCountry; */
/* run; */

**********************;
* Use PROC MDSUMMARY *;
**********************;
* The MDSUMMARY procedure computes basic descriptive statistics for variables across all observations        *; 
* or within groups of observations in parallel for data tables stored in SAS Cloud Analytic Services (CAS).  *; 
* The MDSUMMARY procedure uses CAS tables and capabilities, ensuring full use of parallel processing.        *;
proc mdsummary data=ate_cas.orders_demo_final;
    groupby Country Year;
    var TotalCost TotalPrice Profit;
    output out=ate_cas.orders_summary;
quit;

* Print the entire table from MDSUMMARY *;
proc print data=ate_cas.orders_summary;
run;

* Print only the specified columns and add a format from the output of MDSUMMARY *;
proc print data=ate_cas.orders_summary(rename=_Sum_ = Total);
    var Country Year Total;
    format Total dollar20.2;
run;


* Terminate the CAS session *;
cas conn terminate;


/* Stop timer */
data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;
************************************************************;
* USE THE CAS LANGUAGE(CASL) TO PROCESS DATA IN CAS        *;
************************************************************;

************************************************;
* CHANGE THE PATH WHERE THE DATA IS LOCATED    *;
************************************************;
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let serverPath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,)); *<-----Change path and folder if necessary *;


/* Start timer */
%let _timer_start = %sysfunc(datetime());  

* Connect to CAS and turn on metrics *;
cas conn sessopts=(metrics=True);


* Load the files into memory *;
proc cas;
    table.addCaslib / path="&serverPath", caslib='ate_cas';
    loadFilesIntoMemory = {'orders_demo.sashdat', 'discount_lookup.sas7bdat'};
    do file over loadFilesIntoMemory;
        table.loadTable / 
            path = file, caslib = 'ate_cas',
            casout = {caslib='ate_cas', replace=TRUE};
    end;
quit;


proc cas;
    * Reference the CAS table orders_demo *;
    ordersTbl = {name='orders_demo', caslib='ate_cas'};
    
    * Print 10 rows of the CAS table *;
    table.fetch /
        table = ordersTbl, 
        index=False, 
        to=10;

    * Compute summary statistics (Like PROC MEANS) *;
    simple.summary / table=ordersTbl;


    * Execute data step using an action *;
    source ds_code;
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
    endsource;
    dataStep.runCode / code=ds_code;

    * Reference the prepared orders_demo_calc_columns CAS table *;
    orders_demo_calc_columns ={name='orders_demo_calc_columns', caslib='ate_cas'};

    * Use the freqTab action (PROC FREQTAB) *;
    freqTab.freqTab /
        table =orders_demo_calc_columns ,
        tabulate = {'Product', 'Country', 'DiscountCode', 'Return', 'Year'};

    * Preivew the tables to join *;
    table.fetch / table = orders_demo_calc_columns, index=False, to=10;
    table.fetch / table={name='discount_lookup', caslib='ate_cas'}, index=False, to=10;


    * Join with the Discount Lookup table using the fedsql action *;
    source join_query;
        create table ate_cas.orders_demo_final as
        select f.*, 
           l.pct_discount * .01 as pctDiscount, 
           l.discount_description
        from ate_cas.orders_demo_calc_columns as f left join 
             ate_cas.discount_lookup as l
        on f.DiscountCode = l.discountCode;
    endsource;
    fedSQL.execDirect / query = join_query;

    * Preview the newly joined data *;
    table.fetch / table={name='orders_demo_final', caslib='ate_cas'};

    * Compute final grouped summary statistics (PROC MDSUMMARY/PROC MEANS) *;
    simple.summary /
        table={name='orders_demo_final', 
               caslib='ate_cas',
               groupby={'Country','Year'}},
        subset='SUM',
        inputs={'TotalCost','TotalPrice','Profit'},
        casout={name='orders_summary', caslib='ate_cas'};

    * Preview the new summary statistics table *;
    table.fetch / table={name='orders_summary', caslib='ate_cas'};
    
quit;


* Terminate the CAS session *;
cas conn terminate;



/* Stop timer */
data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;
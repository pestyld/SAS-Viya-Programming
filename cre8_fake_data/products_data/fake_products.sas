***********************************************************************;
* WARNING: PLEASE READ THE FOLLOWING NOTES!                           *;
***********************************************************************;
* - This program creates the following number of rows PER THREAD      *;
* - For the blogs I use 8000000 for the value in create_nRows, and 10 *;
*   for the number of threads to use                                  *;
***********************************************************************;

cas conn;
libname casuser cas caslib='casuser';


proc cas;
    create_nRows = 10;              *<--- Enter number of rows per thread *;
    number_of_threads_to_use = 10;  *<--- Specify 'MAX' for all threads *;

    source ds;

    data casuser.products;
       length Product varchar(10) DiscountCode varchar(10) Return varchar(3);
       call streaminit(99);
        do i=1 to nrows; *<----Replace this value with the create_nRows value prior to execution *;
        *StoreID*;
            StoreID=int(rand('CHISQ', 20));
    
        *Country*;
            *rand_Countries=rand("table",);
    
        *product*;
            array products_groups[4] varchar(10) _temporary_ ("Sweatshirt","Pants","Shirts","Hats");   
            rand_Products=rand("table",.2,.3,.4,.1);
            Product=products_groups[rand_Products];
    
        *product price*;
        array products_price[4] _temporary_ (10.99,8.99,7.99,4.99);
            Price=products_price[rand_Products];
      
        *product cost*;
        array products_cost[4] _temporary_ (1.99,1.49,1.99,.99);      
            Cost=products_cost[rand_Products];
        
        *quantity*;
            Quantity=ceil(rand('BINOM', 0.75, 10));
        
        *return*;
        rand_return=rand('uniform',0,1);
            if (product="Sweatshirt" and rand_return<.02) then Return="Yes";
            else if (product="Pants" and rand_return<.05) then Return="Yes";
            else if (product="Shirts" and rand_return<.08) then Return="Yes";
            else if (product="Hats" and rand_return<.01) then Return="Yes";
            else Return="";
    
        *discount code*;
        rand_discountValue=rand("table",.3,.15,.25,.09,.01,.15,.05);
        rand_discountApplied=rand('uniform',0,1);
        array products_discounts[7] varchar(10) _temporary_ ("TC10","BB20","TENOFF","EMP50","FMDISCOUNT","SPC","FREEDEAL");  
        if rand_DiscountAPplied <.20 then DiscountCode=products_discounts[rand_discountValue];
            else DiscountCode="";
    
         output;
           
        end;
        
        drop i rand:;
    run;
    endsource;

    * Make the numeric value in create_nRows a character to add to the DATA step string *;
    create_nRows = strip(putn(create_nRows,'best16.'));
    ds = tranwrd(ds, 'nrows', create_nRows);

    * Execute the DATA step code for n number of threads *;
    dataStep.runCode / code=ds nthreads = number_of_threads_to_use;
quit;


* Preview the new table *;
proc cas;
    table.fetch / table='products';
quit;
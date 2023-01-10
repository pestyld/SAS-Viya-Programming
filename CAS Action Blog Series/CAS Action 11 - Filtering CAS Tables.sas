*************************************************;
* CAS-Action! Filtering Rows in CAS Tables      *;
*************************************************;
* Connect to the CAS server and name the connection CONN *;
cas conn;

* Create a libref to the CASUSER caslib *;
libname casuser cas caslib="casuser";


****************************************;
* Create the products CAS table        *;
****************************************;
***********************************************************************;
* WARNING: PLEASE READ THE FOLLOWING NOTES!                           *;
***********************************************************************;
* - This program creates the following number of rows PER THREAD      *;
* - For the blogs I use 8000000 for the value in create_nRows, and 10 *;
*   for the number of threads to use                                  *;
***********************************************************************;
proc cas;
* Number of rows to create *;
    create_nRows = 10;              *<--- Enter number of rows per thread (default 10) *;
    number_of_threads_to_use = 10;  *<--- Specify 'MAX' for all threads *;


* Store the DATA step in a variable *;
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
	table.tableDetails / table='products';
quit;




*****;
* 1 *;
*****;
* Preview the CAS Table *;
proc cas;
    productsTbl = {name = 'products', caslib = 'casuser'};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;


*****;
* 2 *;
*****;
* Create a Simple Filter *;
proc cas;
    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   where = 'Product = "Hats"'};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;


*****;
* 3 *;
*****;
* Use a SAS Function to Filter a CAS Table *;
proc cas;
    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   where = 'upcase(Product) = "HATS"'};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;


*****;
* 4 *;
*****;
* Multiple WHERE Expressions *;
proc cas;
    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   where = 'upcase(Product) = "HATS" and StoreID < 15'};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;


*****;
* 5 *;
*****;
* Create a Calculated Column as a Filter *;
proc cas;
    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   where = 'upcase(Product) = "HATS" and 
                            StoreID < 15 and 
                            Price * Quantity > 40'};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;



*****;
* 6 *;
*****;
* Storing the Where Expressions in a Variable *;
proc cas;
    source filter;
        upcase(Product) = "HATS" and 
        StoreID < 15 and 
        Price * Quantity > 40;
    endsource;
    
    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   where = filter};

    simple.numRows / table = productsTbl;
    table.fetch / table = productsTbl;
quit;
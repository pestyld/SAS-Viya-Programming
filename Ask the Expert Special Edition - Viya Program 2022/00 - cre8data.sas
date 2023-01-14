/**********************************************************;
* Ask the Expert Special Edition: Programming in SAS Viya *;
***********************************************************;
PROGRAM: 00 - cre8data.sas
CREATED BY: Peter S
DATE CREATED: May 13, 2022

PROGRAM PURPOSE: 
    1. This program creates the necessary 3 tables for the ask the expert presentation in a specified folder.
       It uses the DATA step to create two tables in the user specified folder location. It then uses the CAS
       server to load the orders files into memory and save it as a sashdat file.

***REQUIREMENTS:    
    1. You will need a folder location that both the CAS server and Compute server can access in 
       your environment with read/write access. If you do not have a location both can access, this
       will not execute.
    2. Modify the serverPath macro variable to point to that folder location.
    3. Specify the number of rows to create in the numRowsCreate macro variable. The presentation 
       creates a table with a default of 10 million rows.

FILE(S) CREATED:
    1. orders_demo.sas7bdat - a fake orders table with n number of rows based on the numRowsCreate macro variable
    2. discount_lookup.sas7bdat - a lookup table for discount codes used for a join
    3. orders_demo.sashdat - The orders_demo.sas7bdat table saved as a sashdat file to show how this 
                             table loads into CAS faster.
**********************************************************/

**************************************************;
* 1. CHANGE THE PATH WHERE THE DATA IS CREATED   *;
**************************************************;
* REQUIRES a writeable path both the CAS server  *;
* and Compute can access                         *;
**************************************************;
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let serverPath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,)); *<-----Change path and folder if necessary *;


************************************************;
* 2. SPECIFY THE NUMBER OF ROWS TO CREATE      *;
************************************************;
%let numRowsCreate=10000000;    *<----number of rows to create. Default 10 million *;



*************************************DO NOT MODIFY THE CODE BELOW **********************************************;
* Create a library reference to the folder location specified *;
libname o "&serverPath";

* Create a fake orders_demo.sas7bdat and discount_lookup.sas7bdat table *;
data o.orders_demo;

     call streaminit(99);
     length Product varchar(10) 
            Country varchar(2)
            OrderDate 8.
            DiscountCode varchar(10) 
            Return varchar(3);

            do i=1 to &numRowsCreate;

            *StoreID*;
                StoreID=int(rand('CHISQ', 20));
        
            *Country*;
                array country_groups[5] varchar(10) _temporary_ ("GR","US","AU","EN", "CA");   
                rand_Countries=rand("table",.2, .4, .1, .1, .2);
                Country=country_groups[rand_Countries];
        
            *Product*;
                array products_groups[4] varchar(10) _temporary_ ("Sweatshirt","Pants","Shirts","Hats");   
                rand_Products=rand("table",.2,.3,.4,.1);
                Product=products_groups[rand_Products];
        
            *Order date*;
                array year_groups[5]  _temporary_ (2017, 2018, 2019, 2020, 2021);   
                rand_year=rand("table",.1,.15,.22,.20,.33);
                OrderDate=int(rand('uniform',mdy(1,1,year_groups[rand_year]), mdy(12,31,year_groups[rand_year])));
        
            *Quantity*;
                Quantity=round(rand('uniform', 20, 500),5);
        
            *product price - customer price*;
            array products_price[4] _temporary_ (10.99,8.99,7.99,4.99);
                Price=products_price[rand_Products];
                  if Quantity > 400 then Price = round(Price * .8,.01);
                    else if Quantity > 300 then Price = round(Price * .85,.01);
                    else if Quantity > 200 then Price = round(Price * .9,.01);
                    else if Quantity > 100 then Price = round(Price * .95,.01);
        
            *product cost - cost to make*;
            array products_cost[4] _temporary_ (1.99,1.49,1.99,.99);      
                Cost=products_cost[rand_Products];
        
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
        format OrderDate date9.;
        drop i rand:;
run;

* Create the lookup table *;
data o.discount_lookup;
     length DiscountCode $15. Discount_Description $30.;
     count = 0;
     array array_pct_discount[7] _temporary_ (10,20,10,50,25,30,100);
     array array_disc_reason[7] varchar(40) _temporary_ ('summer discount', 
                                                         'TV special discount', 
                                                         'email signup discount', 
                                                         'employee discount', 
                                                         'family discount',
                                                         'holiday special discount',
                                                         'free discount code');
     do discountCode ="TC10","BB20","TENOFF","EMP50","FMDISCOUNT","SPC","FREEDEAL";
        count = count + 1;
        pct_discount = array_pct_discount[count];
        discount_description = array_disc_reason[count];
        output;
     end;
     drop count;
run;



***************************************;
* Create the orders_demo.sashdat file *;
***************************************;

* Connect to the CAS server *;
cas conn;

* Create a caslib reference for the CAS server to the same folder location *;
caslib ate path="&serverPath";

* Load the orders_demo.sas7bdat file into CAS and save it as a sashdat file *;
proc cas;
    * Load the table into memory *;
    table.loadTable / 
        path='orders_demo.sas7bdat', 
        caslib='ate', 
        casout={caslib='ate', replace=TRUE};

    * Save it as a sashdat file *;
    table.save / 
        caslib='ate', 
        table='orders_demo',
        name='orders_demo.sashdat'
        replace=TRUE;
    end;
quit;

cas conn terminate;

*****************************************************;
* CAS-Action! Create Columns in CAS Tables - Part 2 *;
*****************************************************;



****************************************;
* Create the products CAS table        *;
****************************************;

* Connect to the CAS server and name the connection CONN *;
cas conn;

* Create a libref to the CASUSER caslib *;
libname casuser cas caslib="casuser";

* Create the fake data by specifying the the path and file to create the fake data *;
%let fake_data_path = /*fakeProductsData.sas*/;
%include "&fake_data_path";


*****;
* 1 *;
*****;
*  Create Calculated Columns and Preview *;
proc cas;
    source createColumns;
        Total_Price = Price * Quantity;
        Product_fix = upcase(Product);
        if Return = "" then Return_fix = "No"; 
           else Return_fix = "Yes";
    endsource;

    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   computedVarsProgram = createColumns
    }; 

    table.fetch / table = productsTbl;
quit;


*****;
* 2 *;
*****;
* Add Formats to a Computed Column *;
proc cas;
    source createColumns;
        Total_Price = Price * Quantity;
        Product_fix = upcase(Product);
        if Return = "" then Return_fix = "No"; 
           else Return_fix = "Yes";
    endsource;

    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   computedVars = {
                            {name = 'Total_Price', format = 'dollar16.2'}
                   },
                   computedVarsProgram = createColumns
    }; 

    table.fetch / table = productsTbl;
quit;


*****;
* 3 *;
*****;
* Add Formats to a Computed Column *;

proc cas;
    source createColumns;
        Total_Price = Price * Quantity;
        Product_fix = upcase(Product);
        if Return = "" then Return_fix = "No"; 
           else Return_fix = "Yes";
    endsource;

    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   computedVars = {
                            {name = 'Total_Price', format = 'dollar16.2'},
                            {name = 'Product_fix'},
                            {name = 'Return_fix'}
                   },
                   computedVarsProgram = createColumns
    }; 

    table.fetch / table = productsTbl;
quit;


*****;
* 4 *;
*****;
* Modify Computed Column Lengths *;
proc cas;
    source createColumns;
        Total_Price = Price * Quantity;
        Product_fix = upcase(Product);

        length Return_fix varchar(3);
        if Return = "" then Return_fix = "No"; 
           else Return_fix = "Yes";
    endsource;

    productsTbl = {name = 'products', 
                   caslib = 'casuser',
                   computedVars = {
                            {name = 'Total_Price', format = 'dollar16.2'},
                            {name = 'Product_fix'},
                            {name = 'Return_fix'}
                   },
                   computedVarsProgram = createColumns
    }; 

    table.fetch / table = productsTbl;
quit;
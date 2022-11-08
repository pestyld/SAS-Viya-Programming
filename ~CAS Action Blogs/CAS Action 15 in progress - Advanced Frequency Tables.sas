*************************************************;
* CAS-Action! Advanced Frequency Tables         *;
*************************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;

* Connect to the CAS server and name the connection CONN *;
cas conn;

* Create a libref to the CASUSER caslib *;
libname casuser cas caslib="casuser";

* Create the fake data by specifying the the path and file to create the fake data *;
%let fake_data_path = /shared/home/Peter.Styliadis@sas.com/SAS Viya Blogs/fakeProductsData.sas;
%include "&fake_data_path";


proc cas;
    tbl = {name="products", caslib="casuser"};
    table.fetch / table = tbl;
quit;

*****;
* 1 *;
*****;
*  *;
proc cas;
    tbl = {name="products", caslib="casuser"};
    loadactionset 'freqtab';
    
    freqTab.freqTab / 
        table = tbl,
        tabulate = 'Product';
quit;





*****;
* 2 *;
*****;
* Specifying Multiple Columns *;
proc cas;
    tbl = {name="products", caslib="casuser"};
    loadactionset 'freqtab';
    
    freqTab.freqTab / 
        table = tbl,
        tabulate = {
                'Product',
                'DiscountCode'
        },
        includeMissing = TRUE
;
quit;


*****;
* 3 *;
*****;
* *;
proc cas;
    tbl = {name="products", 
           caslib="casuser"};
    loadactionset 'freqtab';
    
    freqTab.freqTab / 
        table = tbl,
        tabulate = {
                'Product',
                'DiscountCode',
                {vars = 'Product', cross = {'Return', 'DiscountCode'}}
        },
        includeMissing = TRUE
;
quit;


*****;
* 4 *;
*****;
* *;
proc cas;
    tbl = {name="products", 
           caslib="casuser"};
    loadactionset 'freqtab';
    
    freqTab.freqTab result=ft_results / 
        table = tbl,
        tabulate = {
                'Product',
                'DiscountCode',
                {vars = 'Product', cross = {'Return', 'DiscountCode'}}
        },
        includeMissing = TRUE
    
    ;   
    describe ft_results;

    tbl = ft_results['Table3.CrossList'];
    print tbl;
    saveresult tbl dataout=work.product_by_return;
quit;


*****;
* 5 *;
*****;





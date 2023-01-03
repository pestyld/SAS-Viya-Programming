******************************************;
* CAS-Action! Simply Distinct - Part 1   *;
******************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;
cas conn;

* Set a libref to the casuser caslib *;
libname casuser cas caslib="casuser";

data casuser.cars;
    set sashelp.cars;
run;



*****;
* 1 *;
*****;
* View the number of distinct and missing values for every column *;
proc cas;
    simple.distinct /
        table={name="cars", caslib="casuser"};
quit;



*****;
* 2 *;
*****;
* Specify the columns in the distinct action *;
proc cas;
    simple.distinct /
        table={name="cars", caslib="casuser"},
        inputs={"Make","Origin","Type"};
quit;



*****;
* 3 *;
*****;
* Create a CAS table with the distinct action *;
proc cas;
    simple.distinct /
        table={name="cars", caslib="casuser"},
        casOut={name="distinctCars", caslib="casuser"};
quit;



*****;
* 4 *;
*****;
* Visualize the number of distinct values in every column *;
title justify=left height=14pt "Number of Distinct Values for Each Column in the CARS Table";
proc sgplot data=casuser.distinctCars
            noborder nowall;
    vbar _Column_ / 
        response=_NDis_
        categoryorder=respdesc
        nooutline
        fillattrs=(color=cx0379cd);
    yaxis display=(NOLABEL);
    xaxis display=(NOLABEL);
quit;
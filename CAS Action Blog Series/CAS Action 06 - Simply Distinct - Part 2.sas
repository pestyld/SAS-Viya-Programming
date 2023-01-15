******************************************;
* CAS-Action! Simply Distinct - Part 2   *;
******************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;
cas conn;

libname casuser cas caslib="casuser";

data casuser.cars;
    set sashelp.cars;
run;



*****;
* 1 *;
*****;
proc cas;
    simple.numRows result=n / table={name="cars",caslib="casuser"};
    describe n;
    print n;
quit;



*****;
* 2 *;
*****;
proc cas;
    simple.distinct result=d /
        table={name="cars",caslib="casuser"};
    print d;
quit;



*****;
* 3 *;
*****;
proc cas;
    casTbl={name="cars", caslib="casuser"};

* Store the number of rows in the CAS table *;
    simple.numRows result=n / table=casTbl;

* Store the number of distinct values in each column *;
    simple.distinct result=d /
        table=casTbl;

* Calculate the percentage of distinct values in each column *;
    pctDistinct=d.Distinct.compute({"PctDistinct","Percent Distinct",percent7.2}, nDistinct/n.numRows)
                           [,{"Column","NDistinct","PctDistinct"}];
    print pctDistinct;
quit;



*****;
* 4 *;
*****;
* Output to CSV *;

%let outpath=%sysget(HOME); * Main home directory *;


proc cas;

* Specify the CAS table *;
    casTbl={name="cars", caslib="casuser"};

* Store the number of rows in the CAS table *;
    simple.numRows result=n / table=casTbl;

* Store the number of distinct values in each column *;
    simple.distinct result=d /
        table=casTbl;

* Calculate the percentage of distinct values in each column *;
    pctDistinct=d.Distinct.compute({"PctDistinct","Percent Distinct",percent7.2}, nDistinct/n.numRows)
                           [,{"Column","NDistinct","PctDistinct"}];
    print pctDistinct;

* Save the result table as a CSV file *;
    saveresult pctDistinct csv="&outpath/pctDistinctCars.csv";
quit;
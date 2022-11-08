*************************************************;
* CAS-Action! Show Me the Columns!              *;
*************************************************;



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
    table.columnInfo / table={name="cars", caslib="casuser"};
quit;



*****;
* 2 *;
*****;
proc cas;
* Store the results of the columnInfo action *;
    table.columnInfo result=ci / table={name="cars", caslib="casuser"};

* Access the dictionary from the columnInfo action and create computed columns on the result table *;
    ciTbl = ci.ColumnInfo.compute({"TableName","Table Name"}, "cars")
                         .compute({"Caslib"}, "casuser");
* Print the new result table as confirmation *;
    print ciTbl;

* Save the result table as a CSV file in the specified folder *;
    outpath=/******Specify a folder as a string*****/;
    saveresult ciTbl csv=outpath || "carsDataDictionary.csv";
quit;
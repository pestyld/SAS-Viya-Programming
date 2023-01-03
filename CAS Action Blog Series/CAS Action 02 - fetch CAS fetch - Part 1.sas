****************************************;
* CAS-Action! fetch CAS, fetch! Part 1 *;
****************************************;
* Blog: https://blogs.sas.com/content/sgf/2021/08/06/cas-action-a-series-on-fundamentals/*;


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
* Retrieve the first 20 rows of a CAS table *;
proc cas; 
    table.fetch / table={name="cars", caslib="casuser"}; 
quit;



*****;
* 2 *;
*****;
* Retrieve the First n Rows of a CAS Table *;
proc cas;
    table.fetch / 
        table={name="cars", caslib="casuser"},
        to=5,
        index=FALSE;
quit;



*****;
* 3 *;
*****;
* Sort the Table *;
proc cas;
    table.fetch / 
        table={name="cars", caslib="casuser"},
        sortBy={
            {name="Make", order="DESCENDING"},
            {name="MSRP", order="DESCENDING"}
        },
        index=FALSE;
quit;



*****;
* 4 *;
*****;
* Subset the Table *;
proc cas;
    table.fetch / 
        table={name="cars", caslib="casuser",
               where="Make='Toyota'",
               vars={"Make","Model","MSRP","Invoice"}
        },
        to=5,
        index=FALSE;
quit;



*****;
* 5 *;
*****;
* Create a Calculated Column *;
proc cas;
    table.fetch / 
        table={name="cars", caslib="casuser",
               vars={"Make","Model","MPG_Avg"},
               where="MPG_Avg > 40",
               computedVarsProgram="MPG_Avg=mean(MPG_City,MPG_Highway)"
        },
        sortBy={
            {name="MPG_Avg", order="DESCENDING"}
        },
        index=FALSE;
quit;
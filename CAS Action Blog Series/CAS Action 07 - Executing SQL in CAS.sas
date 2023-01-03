******************************************;
* CAS-Action! Executing SQL in CAS       *;
******************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;
cas conn;

libname casuser cas caslib="casuser";

data casuser.cars;
    set sashelp.cars;
run;


* Execute a query in CAS *;
proc cas;
    fedSQL.execDirect / 
        query="select Make,
                      Model,
                      MSRP,
                      mean(MPG_City,MPG_Highway) as MPG_Avg
               from casuser.cars
               where Make='Toyota'
               order by MPG_Avg desc";
quit;



* Using the SOURCE block *;
proc cas;
    source MPG_toyota;
        select Make,
               Model,
               MSRP,
               mean(MPG_City,MPG_Highway) as MPG_Avg
        from casuser.cars
        where Make='Toyota'
        order by MPG_Avg desc;
    endsource;

    fedSQL.execDirect / query=MPG_toyota;
quit;
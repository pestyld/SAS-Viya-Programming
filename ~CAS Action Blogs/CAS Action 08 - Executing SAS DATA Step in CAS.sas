*******************************************************;
* CAS-Action! Executing the SAS DATA Step in SAS Viya *;
*******************************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;
cas conn;

libname casuser cas caslib="casuser";

data casuser.cars;
    set sashelp.cars;
run;


* View the distinct Origins *;
proc cas;
    simple.freq / 
        table={name='cars', caslib='casuser'},
        input='Origin';
quit;


* Execute the DATA Step in CAS *;
proc cas;
    source originTables;
        data casuser.Asia
             casuser.Europe
             casuser.USA;
            set casuser.cars;
            if Origin='Asia' then output casuser.Asia;
            else if Origin='Europe' then output casuser.Europe;
            else if Origin='USA' then output casuser.USA;
        run;
    endsource;

    dataStep.runCode / code=originTables;
quit;


* Execute DATA Step that is not supported in CAS *;
proc cas;
    source originTables;
        data casuser.bad;
            set casuser.cars;
            NewCol=first(Model);
        run;
    endsource;

    dataStep.runCode / code=originTables;
quit;
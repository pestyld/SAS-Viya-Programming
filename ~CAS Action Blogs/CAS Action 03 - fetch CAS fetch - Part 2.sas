******************************************;
* CAS-Action! fetch CAS, fetch! - Part 2 *;
******************************************;
* Blog: https://blogs.sas.com/content/sgf/2021/08/06/cas-action-a-series-on-fundamentals/*;


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
* Save the results of a CAS action as a SAS data set *;
proc cas;
    table.fetch result=toyota / 
        table={name="cars", caslib="casuser",
               where="Make='Toyota'",
               vars={"Make","Model","MSRP"}
        },
        sortBy={
            {name="MSRP", order="DESCENDING"}
        },
        index=FALSE,
        to=5;

    saveresult toyota.fetch dataout=work.top5;
quit;



*****;
* 2 *;
*****;
* Visualize the CAS table *;
title justify=left height=14pt "Top 5 Toyota Cars by MSRP";
proc sgplot data=work.top5
     noborder nowall;
    vbar Model / 
       response=MSRP 
       categoryorder=respdesc
       nooutline
       fillattrs=(color=cx0379cd);
    label MSRP="MSRP";
quit;
title;
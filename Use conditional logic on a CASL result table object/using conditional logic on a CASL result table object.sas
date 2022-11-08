* Specify a location for your output files. Otherwise delete the ODS statement *;
%let homedir=%sysget(HOME);
%let path=&homedir/SAS Viya/CASL Code/Use conditional logic on a CASL result table object;


cas conn;
libname casuser cas caslib='casuser';

* Create small test CAS table *;
data casuser.cars_test;
    set sashelp.cars(obs=10);
    keep Make Model MSRP Invoice;
run;

ods html5 file="&path/results.html";
proc cas;
    table.fetch result=f / table={name='cars_test', caslib='casuser'}, index=False;

    * Print the original result table object *;
    r_tbl=f.Fetch;
    print r_tbl;

    * Create a new column using conditional logic by casting the expression within the function as a double *;

    *Using IFN to return a numeric *;
    new_tbl_ifn=r_tbl.compute("newCol", ifn((double) (Make="Acura"), 1, 0));
    print  new_tbl_ifn;

    *Using IFC to return a character *;
    * NOTE: Does not work in SAS Viya 3.5 *;
    *new_tbl_ifc=r_tbl.compute("newCol", ifc((double) (Make="Acura"), 'True','False'));
    *print new_tbl_ifc;
quit;
ods html5 close;
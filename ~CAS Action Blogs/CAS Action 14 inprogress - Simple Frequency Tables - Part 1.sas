*************************************************;
* CAS-Action! Simple Frequency Tables           *;
*************************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;

* Connect to the CAS server and name the connection CONN *;
cas conn;

proc cas;
    table.fileInfo / caslib='samples';
    table.loadtable / 
        path = "WATER_CLUSTER.sashdat", caslib = "samples",
        casOut = {name = "warranty_claims", caslib = "casuser", replace=TRUE};

    tbl = {name = "warranty_claims", caslib = "casuser"};
    table.fetch / table = tbl;
    simple.distinct / table = tbl;
    table.columnInfo / table = tbl;
quit;

proc cas;
    colNames = {'primary_labor_group_desc', 'SHIP_YEAR_CD'};
    simple.freq / inputs = colNames;


*****;
* 1 *;
*****;
* One-Way Frequency Table for a Single Column *;
proc cas;
    tbl = {name="products", caslib="casuser"};

    simple.freq / 
        table=tbl,
        inputs = 'Product';
quit;





*****;
* 2 *;
*****;
* Specifying Multiple Columns *;
proc cas;
    tbl = {name="products", caslib="casuser"};
    colNames = {'Product','DiscountCode','Return'};

    simple.freq / 
        table=tbl,
        inputs = colNames;
quit;



*****;
* 3 *;
*****;
* Creating a Calculated Column *;
proc cas;
    source createReturn_fix;
        Return_fix = ifc(Return = 'Yes', Return, 'No');
    endsource;

    tbl = {name="products", 
           caslib="casuser",
           computedVarsProgram = createReturn_fix};
    colNames = {'Product','DiscountCode','Return','Return_fix'};

    simple.freq / 
        table=tbl,
        inputs = colNames;
quit;





*****;
* 4 *;
*****;
* Create a CAS table with the results *;
proc cas;
    source createReturn_fix;
        Return_fix = ifc(Return = 'Yes', Return, 'No');
    endsource;

    tbl = {name="products", 
           caslib="casuser",
           computedVarsProgram = createReturn_fix};
    colNames = {'Product','DiscountCode','Return','Return_fix'};

    simple.freq / 
        table=tbl,
        inputs = colNames,
        casOut={name="freqProducts", caslib="casuser", replace=TRUE};

* Preview the new CAS table *;
    table.fetch / 
       table={name="freqProducts", caslib="casuser"}, index=FALSE;
quit;



*****;
* 5 *;
*****;
* Visualize the CAS table *;

%let txtColor=gray;

ods graphics / width=10in height=6in;

title justify=left height=14pt color=&txtColor  "Number of returns, products sold, etc";
proc sgpanel data=casuser.freqProducts 
             noautolegend;
    panelBy _Column_ / 
        layout=columnlattice 
        sort=descending
        spacing=25 colheaderpos=top
        nowall novarname noheaderborder noborder;
    vbar _FmtVar_ / 
        response=_Frequency_ 
        categoryorder=respdesc
        group = _column_
        nooutline
        datalabel datalabelattrs=(color=&txtColor size=11pt);
    label _Frequency_ = "Total"
          _FmtVar_ = "Column Values";
    rowaxis labelattrs=(size=10pt color=&txtColor)
            display=none;
    colaxis labelattrs=(size=16pt color=&txtColor)
            valueattrs=(size=11pt color=&txtColor)
            display=(nolabel);
    format _Frequency_ comma16.;
run;

ods graphics / reset;
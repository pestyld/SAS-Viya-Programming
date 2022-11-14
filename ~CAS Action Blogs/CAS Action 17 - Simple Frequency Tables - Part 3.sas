*************************************************;
* CAS-Action! Simple Frequency Tables - Part 2  *;
*************************************************;


* Connect to the CAS server and name the connection CONN *;
cas conn;

*************************************************;
* Load the Demonstration Data into Memory       *;
*************************************************;
proc cas;
	* Specify the input/output CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Load the CAS table into memory *;
    table.loadtable / 
        path = "WARRANTY_CLAIMS_0117.sashdat", caslib = "samples",
        casOut = casTbl + {replace=TRUE};

	* Rename columns with the labels. Spaces replaced with underscores *;
	table.columnInfo result=cr / table = casTbl;
	i = 0;
	do columnMetadata over cr.ColumnInfo;
		i = i + 1;
		convertColLabel = tranwrd(columnMetadata['Label'],' ','_');
		renameColumns[i] = {name=columnMetadata['Column'], rename=convertColLabel, label=convertColLabel};
	end;

	* Rename and keep columns *;
	keepColumns = {'Campaign_Type', 'Platform','Trim_Level','Make','Model_Year','Engine_Model',
                   'Vehicle_Assembly_Plant','Claim_Repair_Start_Date', 'Claim_Repair_End_Date'};
	table.alterTable / 
		name = casTbl['Name'], caslib = casTbl['caslib'], 
		columns=renameColumns,
		keep = keepColumns;

	* Preview CAS table *;
	table.fetch / table = casTbl, to = 5;
quit;




*************************************************;
* One-Way Frequency Table for a Single Column   *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    simple.freq / table= casTbl, inputs = 'Make';
quit;



*************************************************;
* One Way Frequency for Multiple Columns        *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    colNames = {'Model_Year', 'Vehicle_Assembly_Plant', 'Engine_Model'};
    simple.freq / table= casTbl, inputs = colNames;
quit;



*************************************************;
* One Way Frequency with a Format               *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    simple.freq / 
		table= casTbl, 
		inputs = 'Claim_Repair_Start_Date';
quit;

proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    simple.freq / 
		table= casTbl, 
		inputs = {
			{name = 'Claim_Repair_Start_Date', format = 'yyq.'}
		};
quit;



*************************************************;
* One Way Frequency by Groups                   *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser", groupby = 'Model_Year'};
    simple.freq / 
		table= casTbl,
		inputs = 'Make';
quit;


proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser", groupby = 'Model_Year'};
    simple.freq result = freqResults / 
		table= casTbl,
		inputs = 'Make',
		casout = {name = 'YearByMake', caslib = 'casuser'};

	table.fetch / table = {name = 'YearByMake', caslib = 'casuser'};
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

cas conn terminate;
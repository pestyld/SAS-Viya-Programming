*************************************************;
* CAS-Action! Simple Frequency Tables - Part 3  *;
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
	table.columnInfo / table = casTbl;
quit;




*************************************************;
* Add a Grouping Column                         *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  groupby = "Model_Year"};
    simple.freq / table = casTbl, input = 'Make';
quit;


proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  groupby = "Model_Year"};

	outputTbl = {name = "yearByMake", caslib = "casuser"};
/*     simple.freq /  */
/* 		table = casTbl,  */
/* 		input = 'Make', */
/* 		casOut = outputTbl || {label = "Year by Make frequency"}; */

	table.fetch / table = outputTbl;
	table.columnInfo / table = outputTbl;
quit;





*************************************************;
* One Way Frequency for Multiple Columns        *;
*************************************************;

cas conn terminate;
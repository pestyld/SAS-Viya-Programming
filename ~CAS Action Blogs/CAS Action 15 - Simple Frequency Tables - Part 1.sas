*************************************************;
* CAS-Action! Simple Frequency Tables - Part 1  *;
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

	*Store the results of the columnInfo action in a dictionary *;
	table.columnInfo result=cr / table = casTbl;

	* Loop over the columnInfo result table and create a list of dictionaries *;
	listElementCounter = 0;
	do columnMetadata over cr.ColumnInfo;
		listElementCounter = listElementCounter + 1;
		convertColLabel = tranwrd(columnMetadata['Label'],' ','_');
		renameColumns[listElementCounter] = {name = columnMetadata['Column'], rename = convertColLabel, label=""};
	end;

	* Rename columns *;
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
* One Way Frequency on a Calculated Column      *;
*************************************************;
proc cas;
	calculateMakePlatform = 'Make_Platform = catx("-",Make,Platform)';
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  computedVarsProgram = calculateMakePlatform};
    simple.freq / 
		table= casTbl,
		inputs = 'Make_Platform';
quit;



cas conn terminate;
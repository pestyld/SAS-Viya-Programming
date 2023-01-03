*************************************************;
* CAS-Action! Grouping Frequency Tables - Part 3*;
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
* Add a Grouping Column                         *;
*************************************************;
proc cas;
	* Reference the CAS table and group by Model_Year *;
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  groupby = "Model_Year"};

	* Model_Year by Make frequency *;
    simple.freq / table = casTbl, input = 'Make';
quit;



*************************************************;
* Saving the results as a CAS table             *;
*************************************************;
proc cas;
	* Reference the CAS table and group by Model_Year *;
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  groupby = "Model_Year"};

	* Specify the output CAS table information *;
	outputTbl = {name = "yearByMake", caslib = "casuser"};

	* Get a frequency of Model_Year by Make and create a CAS table *;
    simple.freq / 
		table = casTbl, 
		input = 'Make',
		casOut = outputTbl || {label = "Year by Make frequency table"};

	* Preview the CAS table *;
	table.fetch / table = outputTbl;
quit;



*************************************************;
* Saving results as a SAS Data Set              *;
*************************************************;
proc cas;
	* Reference the CAS table and group by Model_Year *;
	casTbl = {name = "WARRANTY_CLAIMS", 
			  caslib = "casuser",
			  groupby = "Model_Year"};

	* Specify the output CAS table information *;
	outputTbl = {name = "yearByMake", caslib = "casuser"};

	* Get a frequency of Model_Year by Make and store the results in a dictionary *;
    simple.freq result=freq_cr / 
		table = casTbl, 
		input = 'Make';

	* Combine all the tables in the dictionary and create a result table *;
	freqTbl = combine_tables(freq_cr);

	* Save the result table as a SAS data set *;
	saveresult freqTbl dataout=work.yearByMake;
quit;


* Preview the SAS data set *;
proc print data=work.yearByMake;
run;



*************************************************;
* Plot the results of the freq Action           *;
*************************************************;
title height=14pt justify=left "Total number of warranty claims by year and car make";
title2 "";
proc sgplot data=work.yearByMake
			noborder;
	vline Model_Year / 
			group = CharVar 
			Response=Frequency
			markers;
	format Frequency comma16.;
	keylegend / position=topleft title='Car Makes';
	label Frequency='Warranty Claims';
	xaxis display=(nolabel);
run;
title;

cas conn terminate;
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
* One Way Frequency for Multiple Columns        *;
*************************************************;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    colNames = {'Model_Year', 
				'Vehicle_Assembly_Plant', 
				{name = 'Claim_Repair_Start_Date', format = 'yyq.'}
	};
    simple.freq / table= casTbl, inputs = colNames;
quit;



*************************************************;
* Save the Results as a SAS Data Set            *;
*************************************************;
proc cas;
	* Reference the CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Specify the columns to analyze *;
    colNames = {'Model_Year', 
				'Vehicle_Assembly_Plant', 
				{name = 'Claim_Repair_Start_Date', format = 'yyq.'}
	};

	* Analyze the CAS table *;
    simple.freq result = freq_cr / table= casTbl, inputs = colNames;

	* View the dictionary in the log *;
	describe freq_cr;

	* Save the resul table as a SAS data set *;
	saveresult freq_cr['Frequency'] dataout=work.warranty_freq;
quit;


* Plot the SAS data set *;
title justify=left height=16pt "Total Warranty Claims by Year";
proc sgplot data=work.warranty_freq noborder;
	where Column = 'Model_Year';
	vbar Charvar / 
		response = Frequency
		nooutline;
	xaxis display=(nolabel);
	label Frequency = 'Total Claims';
	format Frequency comma16.;
quit;



*************************************************;
* Save the Results as a CAS Table               *;
*************************************************;
proc cas;
	* Reference the CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Specify the columns to analyze *;
    colNames = {'Model_Year', 
				'Vehicle_Assembly_Plant', 
				{name = 'Claim_Repair_Start_Date', format = 'yyq.'}
    };

	* Analyze the CAS table and create a new CAS table *;
    simple.freq / 
		table= casTbl, 
		inputs = colNames,
		casOut = {
			name = 'warranty_freq',
			caslib = 'casuser',
			label = 'Frequency analysis by year, assembly plant and repair date by quarter'
		};
quit;


* Make a library reference to a Caslib *;
libname casuser cas caslib='casuser';


* Plot the SAS data set *;
title justify=left height=16pt "Total Warranty Claims by Year";
proc sgplot data=casuser.warranty_freq noborder;
	where _Column_ = 'Model_Year';
	vbar _Charvar_ / 
		response = _Frequency_
		nooutline;
	xaxis display=(nolabel);
	label _Frequency_ = 'Total Claims';
	format _Frequency_ comma16.;
quit;


* Terminate the CAS session *;
cas conn terminate;
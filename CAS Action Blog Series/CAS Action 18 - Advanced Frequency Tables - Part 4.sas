**************************************************;
* CAS-Action! Advanced Frequency Tables - Part 4 *;
**************************************************;

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
* One-way frequency tables                      *;
*************************************************;
proc cas;
	* CAS table reference *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

    * One-way frequency tables *;
    freqTab.freqTab / 
        table = casTbl,
        tabulate = {'Campaign_Type','Make'};
quit;



*************************************************;
* Two-way crosstabulation tables                *;
*************************************************;
proc cas;
	* CAS table reference *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    
	* One-way frequency and two-way crosstabulation tables *;
    freqTab.freqTab / 
        table = casTbl,
        tabulate = {
					'Campaign_Type',
					'Make',
                	{vars = 'Make', cross = {'Campaign_Type', 'Model_Year'}}
        };
quit;



******************************************************;
* Two-way crosstabulation as a single table  *;
******************************************************;
proc cas;
	* CAS table reference *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

    * Two-way crosstabulation as a single table *;
    freqTab.freqTab / 
        table = casTbl,
        tabulate = {
                	{vars = 'Make', cross = {'Campaign_Type', 'Model_Year'}}
        }, 
		tabDisplay='list';
quit;



*****************************************************************;
* Three-way crosstabulation                                     *;
*****************************************************************;
proc cas;
	* CAS table reference *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};
    
	* Three-way crosstabulation table *;
    freqTab.freqTab / 
        table = casTbl,
        tabulate = {
				{vars={'Model_Year','Campaign_Type','Make'}}
		}, 
		tabDisplay='list';
quit;
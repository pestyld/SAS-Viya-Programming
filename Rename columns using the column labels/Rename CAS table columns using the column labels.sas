*************************************************;
* RENAME COLUMNS USING THE COLUMN LABELS        *;
*************************************************;

* Load the WATER_CLUSTER.sashdat table into CAS and preview ;
proc cas;
	* Specify the input/output CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Load the CAS table *;
    table.loadtable / 
        path = "WARRANTY_CLAIMS_0117.sashdat", caslib = "samples",
        casOut = casTbl + {replace=TRUE};

	* Preview the CAS table *;
	table.columnInfo / table=casTbl;
	table.fetch / table=casTbl;
quit;



* Rename the column names using the column labels. Replace label spaces with underscores *;
proc cas;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Get the column metadata and store in a dictionary *;
	table.columnInfo result=cr / table = casTbl;
	
	* Store the table from the cr dictionary *;
	columnInfoTable = cr.ColumnInfo;
	

	* Create a list object *;
	renameColumns = {};

	* Create the counter *;
	i = 0;

	* Loop over the column information table *;
	do columnMetadata over columnInfoTable;
		i = i + 1;
		
		* Store the current column name *;
		columnName = columnMetadata['Column'];

		* Store the column label. Replace spaces with underscores *;
		convertColLabel = tranwrd(columnMetadata['Label'],' ','_');

		* Create a list of dictionaries to rename the column and label *;
		renameColumns[i] = {name=columnName, rename=convertColLabel, label=convertColLabel};
	end;

	* Modify the column name and label of the CAS table *;
	table.alterTable / name = casTbl['Name'], caslib = casTbl['caslib'], columns=renameColumns;

	* Preview the CAS table *;
	table.fetch / table = casTbl, to = 5;
quit;
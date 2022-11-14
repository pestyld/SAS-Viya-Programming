*************************************************;
* CAS-Action! Simple Frequency Tables           *;
*************************************************;

* Connect to the CAS server and name the connection CONN *;
cas conn;



*************************************************;
* Load the Demonstration Data into Memory       *;
*************************************************;

proc cas;
	* Specify the input/output CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

	* Load the CAS table *;
    table.loadtable / 
        path = "WARRANTY_CLAIMS_0117.sashdat", caslib = "samples",
        casOut = casTbl + {replace=TRUE};

	table.columnInfo / table = casTbl;
	table.fetch / table = casTbl, to = 5;
quit;



*************************************************;
* Rename Columns in a CAS Table                *;
*************************************************;
proc cas;
    * Reference the CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

    * Rename columns *;
	table.alterTable / 
		name = casTbl['name'], caslib = casTbl['caslib'],
		columns = {
			{name = 'claim_attribute_1', rename = 'Campaign_Type'},
			{name = 'seller_attribute_5', rename = 'Selling_Dealer'},
			{name = 'product_attribute_1', rename = 'Vehicle_Class'}
		};

    * View column metadata *;
	table.columnInfo / table = casTbl;
quit;



*************************************************;
* Rename all Columns Using the Column Labels     *;
*************************************************;
proc cas;
	* Reference the CAS table *;
	casTbl = {name = "WARRANTY_CLAIMS", caslib = "casuser"};

* Rename columns with the labels. Spaces replaced with underscores *;

	*Store the results of the columnInfo action in a dictionary *;
	table.columnInfo result=cr / table = casTbl;

	* Loop over the columnInfo result table and create a list of dictionaries *;
	listElementCounter = 0;
	do columnMetadata over cr.ColumnInfo;
		listElementCounter = listElementCounter + 1;
		convertColLabel = tranwrd(columnMetadata['Label'],' ','_');
		renameColumns[listElementCounter] = {name = columnMetadata['Column'], rename = convertColLabel};
	end;

	* Rename columns *;
	table.alterTable / 
		name = casTbl['Name'], 
		caslib = casTbl['caslib'], 
		columns=renameColumns;

	* Preview CAS table *;
	table.columnInfo / table = casTbl;
quit;


cas conn terminate;
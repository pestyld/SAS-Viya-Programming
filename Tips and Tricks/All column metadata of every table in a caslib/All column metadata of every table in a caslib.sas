* Current folder. SAS program must be saved to the location *; 
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));



cas conn;



* Step 1 *;
* Print all column metadata for each table in a caslib *;
proc cas;
    caslibName = 'Samples';
    table.tableInfo result=ti / caslib=caslibName;
    allCASTablesInCaslib = ti.TableInfo[,'Name'];
    do casTableName over allCASTablesInCaslib;
        table.columnInfo / table={Name = casTableName, caslib=caslibName};
        
    end;
quit;




* Step 2 *;
* Stores the results of all column metadata of each table in a caslib in a single SAS data *;
proc cas;
    caslibName = 'Samples';

    * Get each table name in the specified caslib and store in a list *;
    table.tableInfo result=ti / caslib=caslibName;
    allCASTablesInCaslib = ti.TableInfo[,'Name'];

    * Loop over each table in a caslib and obtain the column information. Store the results in a dictionary *;
    do casTableName over allCASTablesInCaslib;

        * Get the column information of a table *;
        table.columnInfo result=ci / table={Name = casTableName, caslib=caslibName};

        * Add the caslib name and table name to the table of column metadata *;
        tbl = ci.columnInfo.compute('TableName', casTableName)
                           .compute('CaslibName', caslibName);

        * Create a dictionary with each table of column metadata *;
        columnInformationTablesDict[casTableName] = tbl;
    end;

    * Combine each table in the dictionary and make one big table *;
    ColumnMetadataTable = combine_tables(columnInformationTablesDict);

    * Save it as a SAS data set *;
    saveresult ColumnMetadataTable dataout=work.allColumnMetadata;

	* Save as a CAS table *;
    saveresult ColumnMetadataTable caslib='casuser' casout='allColumnMetadata';
quit;




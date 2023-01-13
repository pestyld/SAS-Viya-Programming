
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

cas conn;

proc cas;
    * read JSON file. Specify your path *;
   	myFile = readpath("&path./temp.json");       

    * Store as a dictionary *;
    myDict = json2casl(myFile);  

    * access the string value *; 
	longString = myDict['Nested object sample']['Comment']; 
    * Confirm the length of the string is over 32k *; 
	print length(longString);

    * Create a Result Table and add the long string value to the table *;
	result_tbl = newtable('kevinsString', 
				         {'col1'},      /*col name */
					     {'varchar'},    /*col data type */
                         {longString}); /*row value */
	describe result_tbl;

    * Save the result table as a CAS table *;
	saveresult result_tbl caslib='casuser' casout='longstringCASTable' replace ;

    * Confirm the CAS table was created with 1 column and 1 row *;
	table.tableInfo / caslib = 'casuser';

    * View the length of the column, confirm it's larger than 32k *;
	table.columnInfo / table={name='LONGSTRINGCASTABLE', caslib = 'casuser'};

quit;







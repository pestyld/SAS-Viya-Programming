cas conn;


* Get a parquet file for test data. Place it in the casuser caslib *;
proc cas;
	table.loadTable / 
		path='WARRANTY_CLAIMS_0117.sashdat', caslib ='samples',
		casout = {name='warranty_claims', caslib = 'casuser'};

	table.save / 
		table = {name='warranty_claims', caslib = 'casuser'},
		name = 'warranty_claims.parquet', caslib = 'casuser' replace=True;
quit;


* Get the size of the parquet file(s) *;
proc cas;
	parquetFile = "WARRANTY_CLAIMS.parquet";
	inputCaslib = 'casuser';

	* Get the total size of each parquet file *;
	table.fileInfo result = cr_size / 
		path=parquetFile,
		caslib = inputCaslib;

	* Store the CAS results table in a variable and view it *;
	fileSizeTable = cr_size['FileInfo'];
	describe fileSizeTable;
	print fileSizeTable;

	* Calculate the total file size and print to the log *;
	TotalFileSize = sum(fileSizetable[,'Size']);
	print "Total Parquet File Size: " || TotalFileSize;


	* Add it to the existing results table as a Total row *;
	addrow(fileSizeTable,{'','','','Total Size',TotalFileSize,.});
	print fileSizeTable;
quit;

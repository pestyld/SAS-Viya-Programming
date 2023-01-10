
proc cas;
	dataSourceCaslib = 'casuser';
	outputCasTable = {name = 'datasource_info', caslib = 'casuser'};

	* View the data source files in a caslib and save the results *;
	table.fileInfo result = fi / caslib = dataSourceCaslib;

	* the results of saving an action result is a dictionary *;
	describe fi;

* Save the table in the dictionary as a CAS table and a SAS data set for whatever reason *;

	* Save it as another CAS table *;
	saveresult fi['FileInfo'] casout=outputCasTable['name'] caslib=outputCasTable['caslib'] replace;

	* Or you can save it as a SAS data set since it's most likely a small table *;
	saveresult fi['FileInfo'] dataout=work.datasource_info;

	* Preview the CAS table *;
	table.fetch / table=outputCasTable;
quit;

* Preview the SAS data set and add a format *;
proc print data=work.datasource_info;
	format ModTime datetime.;
run;
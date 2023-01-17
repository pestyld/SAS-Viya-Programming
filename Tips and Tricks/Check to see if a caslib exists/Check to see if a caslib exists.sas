
* Check and view the results *;
proc cas;
	findCaslib = 'samples';

	* Check if the caslib exists and store the results in dictionary *;
	table.queryCaslib result=caslibExists / caslib=findCaslib;
	describe caslibExists;
	print caslibExists;
quit;



* Use a conditional to do something if it finds the caslib *;
proc cas;
	findCaslib = 'samples';

	* Check if the caslib exists and store the results in dictionary *;
	table.queryCaslib result=caslibExists / caslib=findCaslib;
	describe caslibExists;

	* Access the TRUE/FALSE within the dictionary caslibExists *;
	does_caslib_exist = caslibExists[findCaslib];
	print does_caslib_exist;

	if does_caslib_exist = TRUE then print 'caslib exists';
		else print 'Caslib does not exist';
quit;

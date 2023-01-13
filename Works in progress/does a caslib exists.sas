proc cas;
	findCaslib = 'samples';

	table.queryCaslib result=results1/ caslib=findCaslib;
	describe results1;

	does_caslib_exist = results1[findCaslib];
	print does_caslib_exist;

	if does_caslib_exist = TRUE then print 'caslib exists';
		else print 'Caslib does not exist';
quit;

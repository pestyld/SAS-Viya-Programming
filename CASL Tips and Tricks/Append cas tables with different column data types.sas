cas conn;

libname casuser cas caslib='casuser';

/*fake data 1 - char columns */
data casuser.char_cols;
	length x $10;
	x='peter';
	output;
	x='brina';
	output;
run;

proc contents data=casuser.char_cols;
run;

/* Fake data 2 - with varchar */
data casuser.varchar_cols;
	length x varchar(20);
	x='Mark';
	output;
	x='Kristina';
	output;
run;
proc contents data=casuser.varchar_cols;
run;


/* test code */
proc cas;
	source my_ds_code;
	data casuser.new_cols;
		set casuser.char_cols(rename=(x=x_dummy_char));
		length x varchar(20);
		x = x_dummy_char;
		drop x_dummy_char;
	run;
	endsource;

	dataStep.runCode / code = my_ds_code;
	table.fetch / table='new_cols';
	table.columnInfo / table='new_cols';
run;

/* add append action here to the new CAS table */
proc cas;
	table.append / 
		source = {name = 'new_cols', caslib = 'casuser'},
		target = {name = 'varchar_cols', caslib = 'casuser'};


	table.fetch / table='varchar_cols';
	table.columnInfo / table='varchar_cols';
quit;
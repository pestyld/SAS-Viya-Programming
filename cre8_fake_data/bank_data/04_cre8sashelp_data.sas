

***********************;
* Drop the CAS Tables *;
***********************;
* Drops the CAS tables if they already exists *;
proc cas;
	dropTbls={'cars', 'heart'};
	do tbl over dropTbls;
		table.dropTable / caslib="&outputCaslib", name=tbl, quiet=TRUE;
	end;
run;

********************************************;
* Add SASHELP Tables to the CASUSER Caslib *;
********************************************;
* CARS - Promoted *;
proc casutil;
	load data=sashelp.cars
	     casout='cars'
	     outcaslib="&outputCaslib";
run;

* HEART *;
proc casutil;
	load data=sashelp.heart
	     casout='heart'
	     outcaslib="&outputCaslib";
run;


******************************;
* Save as Data Source Files  *;
******************************;
proc cas;
	table.save / 
		table={name='cars', caslib="&outputCaslib"}
		name='cars.txt', replace=TRUE;
	table.save / 
		table={name='cars', caslib="&outputCaslib"}
		name='cars.sas7bdat', replace=TRUE;
	table.save / 
		table={name='heart', caslib="&outputCaslib"}
		name='heart.sashdat', replace=TRUE;

	table.dropTable /
		caslib="&outputCaslib", name='heart', quiet=TRUE;
quit;
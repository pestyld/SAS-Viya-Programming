%macro head(table, n);
	proc print data=&table(obs=&n);
	run;
%mend;

%head(sashelp.cars, 10)



proc cas;
	function head(tbl, lib);
		table.fetch / table={name=tbl, caslib=lib}; 
	end;
	head('cars', 'casuser');
quit;


proc cas;
	/* Put the function(S) in a .sas program and read them into CASL */
 	myFunctions = readpath("/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/myfunc.sas");
 	/*Execute that SAS program */
	execute(myFunctions);
	/*Now you can see your new function */
	functionlist head;
	/* Run your function */
	head('cars', 'casuser');
run;
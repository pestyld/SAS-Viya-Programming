*************************;
* View Files and Tables *;
*************************;
title justify=left height=18pt color=firebrick "Confirm the CARS CAS table exists in your caslib:";
proc cas;
	table.tableInfo / caslib="&outputCaslib";
quit;
title;

title justify=left height=18pt color=firebrick "Confirm the following tables exists as data source files your caslib:";
title2 justify=left height=14pt color=firebrick "1. loans_raw.sashdat";
title3 justify=left height=14pt color=firebrick "2. customers_raw.csv";
title4 justify=left height=14pt color=firebrick "3. AppRatings.sashdat";
title5 justify=left height=14pt color=firebrick "4. cars.txt";
title6 justify=left height=14pt color=firebrick "5. cars.sas7bdat";
title7 justify=left height=14pt color=firebrick "6. heart.sashdat";


proc cas;
	table.fileInfo / caslib="&outputCaslib";
quit;
title;






********************************************************************;
* Extra Utility: Uncomment to delete course data source files only *;
********************************************************************;
/*
proc cas;
	table.fileInfo result=fi / caslib='casuser';
	dsFileNames={'loans_raw.sashdat','customers_raw.csv','cars.csv','cars.txt','cars.sas7bdat','heart.sashdat'};
	do file over dsFileNames;
		table.deleteSource / source=file, caslib='casuser', quiet=TRUE;
	end;
	table.fileInfo;
quit;
*/




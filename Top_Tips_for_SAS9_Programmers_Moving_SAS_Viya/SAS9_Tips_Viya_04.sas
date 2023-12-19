/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/**********************************************************/
/* 4 - Run DATA step in on the distributed CAS server     */
/**********************************************************/

/* Connect the Compute Server to the distributed CAS Server */
cas conn;

/* Explicity load a file into memory */
proc casutil;
	load casdata='RAND_RETAILDEMO.sashdat' incaslib = 'samples'
		 casout='RAND_RETAILDEMO' outcaslib = 'casuser';
quit;


/* Create a library reference to the CAS table */
libname casuser cas caslib = 'casuser';


/* Preview the CAS table */
proc print data=casuser.rand_retaildemo(obs=10);
run;


/* Run DATA step on the in-memory table in the distributed CAS server and create a new in-memory table */
options msglevel=i; /* <--- View additional log notes */
data casuser.rand_retaildemo_final;
	set casuser.rand_retaildemo end=eof; /* <-- View the number of processing threads */
	Department = upcase(Department);
	Profit = Sales - Cost;
	Location = catx(',',City, Country);
	drop MDY Storechain1 brand_name1;

	/* View number of processing threads and rows per thread */
	if eof=1 then put _NTHREADS_= _THREADID_= _N_=;
run;
options msglevel=n; /* Reset notes to the default */

cas conn terminate;
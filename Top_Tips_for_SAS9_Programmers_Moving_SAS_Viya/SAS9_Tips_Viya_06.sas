/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/**********************************************************/
/* 6 - Execute SQL in the distributed CAS server          */
/**********************************************************/

/* Connect the Compute Server to the distributed CAS Server */
cas conn;

/* Explicity load a file into memory */
proc casutil;
	load casdata='RAND_RETAILDEMO.sashdat' incaslib = 'samples'
		 casout='RAND_RETAILDEMO' outcaslib = 'casuser' replace;
quit;


/* To run SQL in the distributed CAS server you must use FedSQL with the sessref = option and the CAS session name */

/* Simple LIMIT */
proc fedsql sessref=conn;
	select *
	from casuser.rand_retaildemo
	limit 10;
quit;


/* GROUP BY */
proc fedsql sessref=conn;
	select Department, 
		   sum(Sales) as TotalSales, 
           sum(Cost) as TotalCost,
		   sum(Sales) - sum(Cost) as TotalProfit
	from casuser.rand_retaildemo
	group by Department;
quit;


/* Disconnect from the CAS server */
cas conn terminate;
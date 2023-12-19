/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/*******************************************/
/* 3 - Loading data into memory in CAS     */
/*******************************************/


/************************************************************/
/* Connect the Compute Server to the distributed CAS Server */
/************************************************************/
cas conn;



/*******************************************/
/* View data sources connected to SAS Viya */
/*******************************************/

/* View available caslibs (data sources) connected to the CAS cluster */
caslib _all_ list;

/* View available libraries (data sources) to the SAS Compute server */
libname _all_ list;



/******************************************************/
/* View available files in a caslib on the CAS server */
/******************************************************/
/* The samples caslib is available by default. It's similar to the SASHELP 
   library on the Compute Server */

proc casutil;
	list files incaslib = 'samples';
quit;



/*************************************************/
/* Load and view metadata of the in-memory table */
/*************************************************/
proc casutil;

	/* Explicity load a file into memory (fila can be a database table or other file format) */
	load casdata='RAND_RETAILDEMO.sashdat' incaslib = 'samples'
		 casout='RAND_RETAILDEMO' outcaslib = 'casuser';

	/* View available in-memory tables in the Casuser caslib */
	list tables incaslib = 'casuser';

	/* View the contents of the in-memory table */
	contents casdata='RAND_RETAILDEMO' incaslib = 'casuser';
quit;



/***************************/
/* Drop an in-memory table */
/***************************/
proc casutil;
	droptable casdata='RAND_RETAILDEMO' incaslib = 'casuser';
quit;


/**********************************/
/* Disconnect from the CAS server */
/**********************************/
cas conn terminate;
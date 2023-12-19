/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/**********************************************************/
/* 5 - New distributed PROCS for the CAS server           */
/* NOTE: The data is small for training purposes          */
/**********************************************************/


/************************************************************/
/* Connect the Compute Server to the distributed CAS Server */
/************************************************************/
cas conn;


/*******************************************************************/
/* Download the CSV file from the internet and load as a CAS table */
/*******************************************************************/
/* We will use a small sample table for demonstration purposes     */
/*******************************************************************/
%let download_url = https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/home_equity.csv;
filename csv_file url "&download_url";

/* Load the CSV file as a distributed CAS table */
proc casutil;
	load file=csv_file casout='home_equity' outcaslib='casuser';
quit;



/************************************************/
/* Create a library reference to a caslib       */
/************************************************/
libname casuser cas caslib = 'casuser';



/*************************/
/* Preview the CAS table */
/*************************/
proc print data=casuser.home_equity(obs=10);
run;


/*********************************/
/* Descriptive statistics in CAS */
/*********************************/
proc mdsummary data=casuser.home_equity;
	output out=casuser.home_equity_summary;
run;
proc print data=casuser.home_equity_summary;
run;



/*********************************************/
/* Frequencies in the distributed CAS server */
/*********************************************/
proc freqtab data=casuser.home_equity;
	tables BAD REASON JOB NINQ CLNO STATE DIVISION REGION / plots=freqplot;
quit;



/*********************************************/
/* Correlation in the distributed CAS server */
/*********************************************/
proc correlation data=casuser.home_equity;
run;


/*************************************************/
/* View the cardinality of the columns using CAS */
/*************************************************/
/* The CARDINALITY procedure determines a variable’s cardinality or limited cardinality in SAS Viya. 
   The cardinality of a variable is the number of its distinct values, and the limited cardinality of a 
   variable is the number of its distinct values that do not exceed a specified threshold. */
proc cardinality data=casuser.home_equity
				 outcard=casuser.home_equity_cardinality maxlevels=250;
run;
proc print data=casuser.home_equity_cardinality;
run;



/*****************************************************/
/* Logistic regression in the distributed CAS server */
/*****************************************************/
proc logselect;
run;



/**********************************/
/* Disconnect from the CAS server */
/**********************************/
cas conn terminate;
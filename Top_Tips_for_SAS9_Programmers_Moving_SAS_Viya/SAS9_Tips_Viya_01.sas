/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/**********************************/
/* 1 - Run SAS9 Code on SAS Viya! */
/**********************************/

/* Specify the folder to save the CSV file */
/* Find current folder. SAS program must be saved to the location */
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));
%put &=path;


/* Download CSV file URL */
%let download_url = https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/home_equity.csv;

/* Download CSV file from the internet to SAS */
filename out_file "&path/home_equity.csv";
proc http
 	url="&download_url"
 	method="get" 
	out=out_file;
run;


/* Create a SAS table */
proc import datafile="&path/home_equity.csv" 
			dbms=csv 
			out=work.home_equity;
	guessingrows=1000;
run;


/* Preview the SAS table */
proc print data=work.home_equity(obs=10);
run;


/* View column metatdata */
ods select Variables;
proc contents data=work.home_equity;
run;


/* View descriptive statistics */
proc means data=work.home_equity;
run;


/* View number of distinct values in specified columns */
proc sql;
	select count(distinct BAD) as DistinctBAD,	
		   count(distinct REASON) as DistinctREASON,
           count(distinct JOB) as DistinctJOB,
           count(distinct NINQ) as DistinctNINQ,
		   count(distinct CLNO) as DistinctCLNO,
		   count(distinct STATE) as DistinctSTATE,
		   count(distinct DIVISION) as DistinctDIVISION,
		   count(distinct REGION) as DistinctREGION
	from work.home_equity;
quit;


/* View categorical column frequencies */
proc freq data=work.home_equity order=freq nlevels;
	tables BAD REASON JOB NINQ CLNO STATE DIVISION REGION / plots=freqplot missing;
run;


/* View missing values in the table */

/* Create a format to group missing and nonmissing */
proc format;
	value $missfmt 
		' '='Missing' 
		other='Not Missing';
	value missfmt  
		. ='Missing' 
		other='Not Missing';
run;
/* Apply the format in PROC FREQ */
proc freq data=work.home_equity; 
	format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
	tables _CHAR_ / missing missprint nocum nopercent;
	format _NUMERIC_ missfmt.;
	tables _NUMERIC_ / missing missprint nocum nopercent;
run;


/* Find the mean of the following columns to use to replace missing values using PROC SQL */
proc sql;
	select round(mean(YOJ)) as MeanYOJ,
		   round(mean(MORTDUE)) as MeanMORTDUE,
		   round(mean(VALUE)) as MeanVALUE,
		   round(mean(DEBTINC)) as MeanDEBTINC
		into :YOJmean trimmed, 
			 :MORTDUEmean trimmed,
			 :VALUEmean trimmed,
             :DEBTINCmean trimmed
	from work.home_equity;
quit;
%put &=YOJmean &=MORTDUEmean &=VALUEmean &=DEBTINCmean;


/* Prepare the data */
data work.final_home_equity;
	set work.home_equity;

	/* Fix missing values */
	if YOJ = . then YOJ = &YOJmean;
	if MORTDUE = . then MORTDUE = &MORTDUEmean;
	if VALUE = . then VALUE = &VALUEmean;
	if DEBTINC = . then DEBTINC = &DEBTINCmean;

	/* Round column */
	DEBTINC = round(DEBTINC);

	/* Format columns */
	format APPDATE date9.;

	/* Drop columns */
	drop DEROG DELINQ CLAGE NINQ CLNO CITY;
run;


/* Check the final data for missing values */
proc freq data=work.final_home_equity; 
	format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
	tables _CHAR_ / missing missprint nocum nopercent;
	format _NUMERIC_ missfmt.;
	tables _NUMERIC_ / missing missprint nocum nopercent;
run;


/* Preview final data */
proc print data=work.final_home_equity(obs=10);
run;


/* Create a visualization */
title height=14pt justify=left "Current vs Default Loans";
proc sgplot data=work.final_home_equity;
	vbar BAD / datalabel;
run;


/* Create a model to predict bad loans */
proc logistic data=work.final_home_equity;
	class REASON JOB / param=REFERENCE;
	model BAD(event='1') = LOAN MORTDUE VALUE REASON JOB YOJ DEBTINC;
	store mymodel;
run;

/* Apply the model on the data */
proc plm restore=mymodel;
	score data = work.final_home_equity
		  out = work.he_score predicted lclm uclm / ilink;
run;
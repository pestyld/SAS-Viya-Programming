/*******************************************************/
/* FINDING THE CURRENT WORKING DIRECTORY IN SAS STUDIO */
/*******************************************************/

/* View all global macro variables */
%put _global_;

/* View the value of the _SASPROGRAMFILE macro variable */
%put &=_SASPROGRAMFILE;


/*******************************/
/* Development V1              */
/*******************************/

%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let currDirectory = %sysfunc(tranwrd(&_sasprogramfile, /&fileName,));

/* Test */
%put &=currDirectory;



/*******************************/
/* Development V2              */
/*******************************/
%macro getcwd;
	%local fileName currDirectory;
	%let fileName =  %scan(&_sasprogramfile,-1,'/');
	%let currDirectory = %sysfunc(tranwrd(&_sasprogramfile, /&fileName,));
	&currDirectory
%mend;


%let mypath = %getcwd;
%put &=mypath;



/*******************************/
/* Final                       */
/*******************************/
/* Produce an error if the _SASPROGRAMFILE global macro variable is empty */
%macro getcwd;
	/* Create local macro variables */
	%local fileName currDirectory;
	%if &_sasprogramfile= %then %do;
		%put ERROR: The SAS program needs to be saved to find the directory.;
	%end;
	%else %do;
		%let fileName =  %scan(&_sasprogramfile,-1,'/');
		%let currDirectory = %sysfunc(tranwrd(&_sasprogramfile, /&fileName,));
		&currDirectory
	%end;
%mend;

%let mypath = %getcwd;
%put &=mypath;
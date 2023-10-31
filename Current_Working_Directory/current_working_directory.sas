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






















/*******************************/
/* Development                 */
/*******************************/

data dev;
	/* Get the file path */
	filePath = "&_SASPROGRAMFILE";

	/* Get the program name and add the slash at the beginning (optional) */
	programName = cats('/',scan(filePath,-1,'/'));

	/* Remove the program name and slash from the file path */
	currDirectory = tranwrd(filePath, strip(programName),'');

	/* Create a macro variable with the directory path */
	call symputx('_SASPROGRAMDIR', currDirectory);
run;

/* Preview the data set */
proc print data=dev;
run;

%put &=_SASPROGRAMDIR;


/*******************************/
/* Production                  */
/*******************************/
%macro getcwd;
	data _null_;
		/* Get the file path */
		filePath = "&_SASPROGRAMFILE";
	
		/* Get the program name and add the slash at the beginning (optional) */
		programName = cats('/',scan(filePath,-1,'/'));
	
		/* Remove the program name and slash from the file path */
		currDirectory = tranwrd(filePath, strip(programName),'');
	
		/* Create a macro variable with the directory path */
		call symputx('_SASPROGRAMDIR', currDirectory);
	run;

	
	%if 1=1 %then %do;
		test
	%end;
%mend;


%let mypath = %getcwd;
%put &=mypath;

%macro test;
	%if 1=1 %then %do;
		test
	%end;
%mend;


/* return macro variable value here */
%let path = %test();

%put &=path;


%macro obt_max;

	%let max_age=test2;

	&max_age

%mend;

%let max_age2 = %obt_max;
%put &=max_age2;








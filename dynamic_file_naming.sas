/****************************************************************
 Dynamically naming your files with the current date
****************************************************************/
 

/************************************************************
 Step 1: Creating the macro variable with today's date     
************************************************************/

/**************************
 Using the %LET statement
**************************/

%let current_date = %sysfunc(today(), yymm.);

/* View macro variable value */
%put &=current_date;


/**************************
 Using the DATA step
**************************/
data _null_;
	todays_date = put(today(), yymm.);
	
	/* Create macro variable */
	call symputx('current_date', todays_date);	
run;

/* View macro variable value */
%put &=current_date;


/**************************
 Using Python
**************************/
proc python;
submit;

## Get the date
from datetime import date
today = date.today().strftime("%Y-%m-%d")

## Create a SAS macro variable
SAS.symput('current_date_python', today)

endsubmit;
quit;

/* View macro variable value */
%put &=current_date;



/************************************************************
 Step 2: Use the macro variable when creating a table or file     
************************************************************/

/****************************************
 a. Create a SAS table with the current date
****************************************/
data work.toyota_&current_date;
	set sashelp.cars;
	MPG_Avg = mean(MPG_City, MPG_Highway);
	where Make = 'Toyota'; 
run;


/*********************************************
 b. Create an Excel file with the current date
*********************************************/

/* Specify where you want to create the file */
%let outpath = %SYSGET(HOME);

/* Create the Excel file */
ods excel file = "&outpath./Toyota_Report_&current_date..xlsx";

/* Add text to Excel */
proc odstext;
	p "List of cars as of &current_date" / style = [fontsize=18pt] ;
run;

/* Print a list of cars */
proc print data=work.toyota_&current_date noobs;
	var Make Model MSRP Invoice MPG_Avg;
run;

ods excel close;
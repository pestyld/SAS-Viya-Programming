/********************************************************************/
/* 9 for SAS9 – Top Tips for SAS 9 Programmers Moving to SAS Viya   */
/********************************************************************/

/*****************************************/
/* 2 - Check hardcoded paths             */
/*****************************************/

/* Old local path or SAS9 remote server path */
%let path = C:\workshop; /* <----- modify path fromn your old data to your new data */

proc import datafile="&path/home_equity.csv" 
			dbms=csv 
			out=work.new_table;
	guessingrows=1000;
run;



/* New path to data in SAS Viya */
%let path = /newpath/user/home_equity.csv; /* <----- modify path to your new data */

proc import datafile="&path/home_equity.csv" 
			dbms=csv 
			out=work.new_table;
	guessingrows=1000;
run;
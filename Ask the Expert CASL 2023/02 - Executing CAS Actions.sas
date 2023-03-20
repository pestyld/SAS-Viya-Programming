**************************************************;
* Ask the Expert 2023 - CAS Language (CASL)      *;
**************************************************;
* Part 2 - Executing CAS Actions                 *;
**************************************************;

/***********************************************************************************
* DOCUMENTATION                                                                    *
************************************************************************************
* SAS® Cloud Analytic Services: CASL Programmer’s Guide
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/caslpg/titlepage.htm
************************************************************************************
* SAS® Cloud Analytic Services: CASL Reference                                   
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/proccas/titlepage.htm
************************************************************************************
* SAS® Cloud Analytic Services: Fundamentals
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/casfun/titlepage.htm
************************************************************************************
* CAS Action Sets by Name
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/allprodsactions/actionSetsByName.htm
************************************************************************************/


* If necessary, connect to the CAS server through the SAS client (Compute server) *;
cas conn;

**************************************************;
* Executing CAS actions                          *;
**************************************************;
* CAS actions are processed in the distributed CAS server *;

* View available caslibs the distributed CAS server has access to with the table.caslibInfo CAS action *;
proc cas;
	table.caslibInfo;
quit;


* Store the results of a CAS action in a variable *;
proc cas;
	* Execute the action and store the results in the variable casActionResults *;
	table.caslibInfo result=casActionResults;

	* Print and describe the casActionResults variable *;
	print casActionResults;
	describe casActionResults;
quit;


* Store the result table stored in the dictionary returned from the caslibInfo CAS action *;
proc cas;
	table.caslibInfo result=casActionResults;

	* Store the table from the casActionResults by calling the dictionary key *;
	resultTable = casActionResults['CASLibInfo'];

	* Print and describe the resultTable variable *;
	print resultTable;
	describe resultTable;

	* Filter the result table *;
	filteredTable = resultTable                         /* Result table */
                    .where(upcase(Name) like 'P%')      /* Filter */
                    [,{'Name','Type','Path'}];          /* Select columns */

	* Save the result table as a SAS table in the WORK library *;
	saveresult filteredTable dataout=work.caslibs_startwith_p;
quit;

* Print the SAS table using traditional SAS programmming *;
title height=16pt 'Using the PRINT procedure to view the SAS table created from CASL';
proc print data=caslibs_startwith_p;
run;
title;


* View available data sources files  and in-memory tables in a caslib *;
proc cas;
	viewCaslibs = {'samples', 'casuser'};

	do lib over viewCaslibs;
		table.fileInfo / caslib = lib;
		table.tableInfo / caslib = lib;
	end;
quit;


* Load a data source file into memory as a distributed CAS table *;
* If you have used the pandas library before, this is like loading a file into memory as a DataFrame *;
proc cas;
	table.loadTable /
		path = 'RAND_RETAILDEMO.sashdat', caslib = 'samples',
		casOut = {
			name = 'retail',      /* Name of the distributed CAS table */
			caslib = 'casuser',   /* Output in-memory space */
			replace = TRUE        /* Replace if it already exists */
		};
quit;


* View the new distributed CAS table *;
proc cas;
	* View available in-memory tables in the Casuser caslib to confirm retail is available *;
	table.tableInfo / caslib = 'casuser';

	* View information about the distributed retail CAS table *;
	table.tableDetails / name = 'retail', caslib = 'casuser';
quit;


* Explore an in-memory CAS table *;
* CAS actions will process the data in the distributed CAS server and return results to the client (SAS compute) *;
proc cas;
	* Reference the CAS table in the dictionary *;
	retailTbl = {name = 'retail', caslib = 'casuser'};

	* Preview 5 rows of the retail CAS table *;
	table.fetch / 
		table = retailTbl, 
		to = 5;

	* View column attributes of the retail CAS table *;
	table.columnInfo / table = retailTbl;

	* View distinct values of the CAS table *;
	simple.distinct / table = retailTbl;

	* View summary statistics of numeric columns *;
	simple.summary / table = retailTbl;
quit;



******************************************************************;
* GOAL: Plot the frequency values of loyalty_card and Department *;
******************************************************************;
* 1. Use the CAS server to process data in the CAS server        *;
* 2. Store the summarized results as a SAS table                 *;
* 3. Visualize and report using traditional SAS programming      *;
******************************************************************;

* Use the freq action to summarize the data in the distributed CAS server *;
proc cas;
	retailTbl = {name = 'retail', caslib = 'casuser'};

	* Get frequency values on the distributed CAS server and store the results *;
	simple.freq result = freqResults / 
		table = retailTbl, 
		inputs = {'loyalty_card', 'Department'};

	* View and describe the results *;
	print freqResults;
	describe freqResults;
quit;


* Save the results as a SAS data set *;
proc cas;
	retailTbl = {name = 'retail', caslib = 'casuser'};

	* Get frequency values on the distributed CAS server and store the results *;
	simple.freq result = freqResults / 
		table = retailTbl, 
		inputs = {'loyalty_card', 'Department'};

	* Store the result table from the dictoinary using the function *;
	rtbl = findTable(freqResults);

	* Alternate method *;
	*rtbl = freqResults['Frequency'];

	* Save the smaller summarized results as a SAS table *;
	saveresult rtbl dataout=work.retailFreq;
quit;
* Check the WORK library on the compute server. Notice a new SAS table was created *;


*****************************************************;
* Traditional SAS Programming on the CAS results    *;
*****************************************************;
* Visualize the summarized data from the CAS server *;
* on the compute server using traditional SAS and   *;
* export the results to Excel.                      *;
*****************************************************;

ods excel file="&currentPath/ExcelReport.xlsx";

proc print data = work.retailFreq;
run;

%let selectedColumn = %upcase(loyalty_card);

title "Frequency values of: &selectedColumn";
proc sgplot data=work.retailFreq;
	vbar FmtVar / 
		response = Frequency 
		categoryorder = respdesc;
	where upcase(Column) = "&selectedColumn";
quit;

%let selectedColumn = %upcase(Department);

title "Frequency values of: &selectedColumn";
proc sgplot data=work.retailFreq;
	vbar FmtVar / 
		response = Frequency 
		stat = percent
		categoryorder = respdesc;
	where upcase(Column) = "&selectedColumn";
quit;

ods excel close;


******************************************************************;
* GOAL: Execute SQL in the distributed CAS server                *;
******************************************************************;
proc cas;
	* Store your query as a string in the variable myQuery *;
	source myQuery;
		select distinct Department, count (*) as TotalCount
			from casuser.retail
			group by Department
			order by TotalCount;
	endSource;

/* Alternate method */
/* myQuery = ' */
/* 		select distinct Department, count (*) as TotalCount */
/* 			from casuser.retail */
/* 			group by Department */
/* 			order by TotalCount; */
/* '; */

	fedSQL.execDirect /
		query = myQuery;
quit;

* Or use the fedsql procedure and specify your CAS connection *;
proc fedsql sessref = conn;
	select distinct Department, count (*) as TotalCount
		from casuser.retail
		group by Department
		order by TotalCount;
quit;


******************************************************************;
* GOAL: Execute DATA step in the distributed CAS server          *;
******************************************************************;

proc cas;
	* Store your DATA step  as a string in the variable myDataStepCode *;
	source myDataStepCode;
		data casuser.no_loyalty_card
			 casuser.loyalty_card
			 casuser.other;
			set casuser.retail;
			if loyalty_card = 0 then output casuser.no_loyalty_card;
	    	else if loyalty_card = 1 then output casuser.loyalty_card;
			else output casuser.other;
		run;
	endsource;

	* Execute DATA step code *;
	dataStep.runCode /
		code = myDataStepCode;

	* View the new CAS tables *;
	table.tableInfo / caslib = 'casuser';
quit;
	

/************************************************************************************
* CAS Action Sets by Name
* https://go.documentation.sas.com/doc/en/pgmsascdc/default/allprodsactions/actionSetsByName.htm
************************************************************************************/

cas conn terminate;

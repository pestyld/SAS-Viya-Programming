**************************************************;
* Ask the Expert 2023 - CAS Language (CASL)      *;
**************************************************;
* Part 1 - CASL Fundamentals                     *;
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


************************************************************************************************;
* Traditional SAS Programming in SAS Viya                                                      *;
************************************************************************************************;
* - You can still use traditional SAS code in SAS Viya with the SAS compute server.            *;
* - Knowing CASL will add more contorl when you want to accelerate data processing using the   *;
*   CAS server. CASL also gives you different variable data types like lists and dictionaries. *;
************************************************************************************************;

* Current folder path this program resides in (program must be saved in a folder) *;
%let currentPath = %sysfunc(tranwrd(&_sasprogramfile, %scan(&_sasprogramfile,-1,'/'),));

* SAS data set to use*;
%let dataSetName = sashelp.cars;

* DATA step *;
data work.cars_new;
	set &dataSetName;
	MPG_Avg = mean(MPG_City, MPG_Highway);
	keep Make Model Origin MPG_City MPG_Highway MPG_Avg;
run;

* SAS ODS EXCEL *;
ods excel file ="&currentPath/basicExcelReport.xlsx";

* Procedures *;
title "Input table used: &dataSetName";
proc print data = work.cars_new(obs=10);
run;

proc means data = work.cars_new;
	class Origin;
	var MPG_Avg;
run;

proc sgplot data = work.cars_new;
	vbar Origin / response = MPG_Avg stat = mean;
quit;
title;

ods excel close;



*****************************************************************;
* Connect the SAS Client (SAS Compute Server) to the CAS Server *;
*****************************************************************;

* Make a connection to the CAS server *;
cas conn;

* Send commands to the CAS server. About will return information about the CAS server *;
proc cas;
	about;
quit;



********************;
* String variables *;
********************;

* Create a simple string variable *;
proc cas;
	name = 'Peter Styliadis';

	* View the structure and data type of CASL variables and expressions *;
	describe name;

	* Writes the values of constants, variables, and expressions to the log *;
	print name;
quit;


* ERROR - All variables are cleared after the CAS procedures *;
proc cas;
	print name;
quit;


* Using SAS functions and operators on string variables *;
proc cas;
	name = 'Peter Styliadis';
	firstName = scan(name,1);
	lastName = scan(name,2);

	print 'My first name is: ' firstName;
	print 'My last name is : ' lastName;
	print 'My full name is (||) : ' lastName || ', ' || firstName;
	print 'My full name is (cat function): ' cat(lastName,', ',firstName);
quit;



*********************;
* Numeric variables *;
*********************;

proc cas;
* Create a integer variable *;
	x = 100;
	print '*******************';
	describe x;
	print x;
	print '*******************';

* Create a double variable *;
	y = 200.5;
	describe y;
	print y;
	print '*******************';

* Create an expression *;
	totalValue = x + y;
	print totalValue;
	describe totalValue;
	print '*******************';
quit;


* You can use the majority of SAS functions in the CAS language *;
proc cas;
	x = 100;
	y = 200.5;

	totalValue = sum(x,y);
	meanValue = mean(x,y);
	maxValue = max(x,y);
	minValue = min(x,y);

	print '*******************';
	print 'The total value is: ' totalValue;
	print 'The mean value is: ' meanValue;
	print 'The max value is: ' maxValue;
	print 'The min value is: ' minValue;
	print '*******************';
quit;




****************;
* List (array) *;
****************;

* Create a simple list of strings. Lists in CASL required {} *;
proc cas;
	languagesForCAS = {'SAS', 'SQL', 'Python', 'CASL', 'REST','JAVA','R','LUA'};

	print '*******************';
	describe languagesForCAS;
	print languagesForCAS;
	print '*******************';
quit;


* Lists can contain different data types *;
proc cas;
	myInfo = {'Peter', 35, 2, {'Gaea','Millie','Dakota'}};

	print '*******************';
	describe myInfo;
	print myInfo;
	print '*******************';
quit;


* Loop over a list *;
proc cas;
	myInfo = {'Peter', 35, 2, {'Gaea','Millie','Dakota'}};
	counter = 0;

	* Loop over the list *;
	do i over myInfo;
		counter = counter + 1;
		print "List value: " i ", Counter: " counter;
	end;
quit;


* Access elements in a list. CASL lists begin at position 1 *;
proc cas;
	myInfo = {'Peter', 37, 2, {'Gaea','Millie','Dakota'}};
	name = myInfo[1];
	totalKids = myInfo[3];

	print '*******************';
	print name || ' has ' || totalKids || ' kids.';
	print '*******************';
quit;
* NOTE: You must know the position you need in a list *;


****************;
* Dictionary   *;
****************;

* Create a dictionary using the same information as the list above *;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 35, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};

	print '*******************';
	describe myInfo;
	print myInfo;
	print '*******************';
quit;


* Accessing values in a dictionary *;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 37, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};

	name = myInfo['name'];
	totalKids = myInfo['kids'];

	print '*******************';
	print name ' has ' totalKids ' kids.';
	print '*******************';
quit;


* Adding keys/value pairs to a dictionary *;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 37, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};

	print '*******************';
	print myInfo;
	print '*******************';

	print 'Add key to dictionary';
	myInfo['newkey'] = 'New Value';

	print myInfo;
	print '*******************';
quit;



*****************;
* Result tables *;
*****************;
/**************************************************************************************
- These are simply in-memory tables, there is no file on disk like traditional SAS tables
- Results tables reside on the SAS compute server's memory
- These tables are not processed in the CAS server
- Similar to DataFrames if you have used the Python pandas package
**************************************************************************************/

* Create and view a result table *;
proc cas;
	* Create result structure *;
   	columnNames = {"Name", "Age", "Food"};
   	colTypes={"string", "integer", "string"};

	* Create result table *;
   	result_table = newtable("My Table Name", columnNames, colTypes,
							{'Peter', 35, 'Gyros'}   
							{'Eva', 20, 'Muffins'},
							{'Owen', 37, 'Ice Cream'},
							{'Kristi', 20, 'Tacos'});
	
	* Print the result table and it's data type *;
	print result_table;
	describe result_table;
quit;


* Filter a result table and save a result table as a SAS data set  *;
proc cas;
	* Create result table *;
   	columnNames = {"Name", "Age", "Food"};
   	colTypes={"string", "integer", "string"};
   	result_table = newtable("My Table Name", columnNames, colTypes,
							{'Peter', 35, 'Gyros'}   
							{'Eva', 20, 'Muffins'},
							{'Owen', 37, 'Ice Cream'},
							{'Kristi', 20, 'Tacos'});
	print result_table;


	* Print subset of rows and columns of the table *;
	print (result_table            /* Result table */
		   .where(Age > 30)        /* Filter the table */
		   [,{'Name','Food'}]);    /* Select all rows and only the Name and Food columns */


	* Return a list from a column of the result table *;
	nameList = getcolumn(result_table, 'Name');
	print nameList;
	describe nameList;

	* Save the result table as a SAS table *;
	saveresult result_table dataout=work.myresulttable;
quit;


* Use traditional SAS programming the SAS table created from the CASL result table *;
title height=16pt "Age of my friends and family in food choices SAS table ";
proc print data=work.myresulttable;
run;

proc sgplot data=work.myresulttable;
	vbar Name / response=Age;
run;
title;

* Go to program: 02 - Executing CAS Actions.sas *;
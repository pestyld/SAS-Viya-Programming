**************************************************;
* Ask the Expert - CAS Language                  *;
**************************************************;


*****************************************************************;
* Connect the SAS Client (SAS Compute Server) to the CAS Server *;
*****************************************************************;

* Make a connection to the CAS server *;
cas conn;

* View information about the CAS server *;
proc cas;
	about;
quit;



********************;
* String variables *;
********************;

* Create a simple string variable *;
proc cas;
	name = 'Peter Styliadis';
	describe name;
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
	print 'My full name is (cat()): ' cat(lastName,', ',firstName);
quit;



*********************;
* Numeric variables *;
*********************;

* Create a integer variable *;
proc cas;
	x = 100;
	describe x;
	print x;
quit;


* Create a double variable *;
proc cas;
	y = 100.5;
	describe y;
	print y;
quit;


* Create an expression *;
proc cas;
	x = 100;
	y = 150;
	totalValue = x + y;
	print '*******************';
	print totalValue;
quit;


* Use SAS functions on numeric variables *;
proc cas;
	x = 100;
	y = 150;

	totalValue = sum(x,y);
	meanValue = mean(x,y);
	maxValue = max(x,y);
	minValue = min(x,y);

	print 'The total value is: ' totalValue;
	print 'The mean value is: ' meanValue;
	print 'The max value is: ' maxValue;
	print 'The min value is: ' minValue;
quit;



****************;
* List (array) *;
****************;

* Create a simple list of strings *;
proc cas;
	languagesForCAS = {'SAS', 'SQL', 'Python', 'CASL', 'REST','JAVA','R','LUA'};
	describe languagesForCAS;
	print languagesForCAS;
quit;


* Access elements in a list. CASL lists begin at position 1 *;
proc cas;
	languages = {'element1', 'element2', 'element3', 'element4'};
	print languages[1];
quit;

* Select range (incluseive) *;
proc cas;
	languages = {'element1', 'element2', 'element3', 'element4'};
	print languages[1:3];
quit;


* Select specific elements *;
proc cas;
	languages = {'element1', 'element2', 'element3', 'element4'};
	print languages[2,4];
quit;


* Lists can contain different data types *;
proc cas;
	myInfo = {'Peter', 37, 2, {'Gaea','Millie','Dakota'}};
	describe myInfo;
	print myInfo;
quit;


* Loop over a list *;
proc cas;
	myInfo = {'Peter', 37, 2, {'Gaea','Millie','Dakota'}};
	counter = 0;
	do i over myInfo;
		counter = counter + 1;
		print "Element: " i ", Counter: " counter;
	end;
quit;


* Access elements *;
proc cas;
	myInfo = {'Peter', 37, 2, {'Gaea','Millie','Dakota'}};
	name = myInfo[1];
	totalKids = myInfo[3];

	print name || ' has ' || totalKids || ' kids.';
quit;



****************;
* Dictionary   *;
****************;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 37, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};

	describe myInfo;
	print myInfo;
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

	print name ' has ' totalKids ' kids.';
quit;


* Adding keys/value pairs to a dictionary *;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 37, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};
	print myInfo;

	print 'Add key to dictionary';
	myInfo['newkey'] = 'New Value';
	print myInfo;
quit;


* Loop over a dictionary *;
proc cas;
	myInfo = {
			  name = 'Peter', 
              age = 37, 
			  kids = 2, 
			  dogs = {'Gaea','Millie','Dakota'}
	};

	do key, value over myInfo;
		print 'The key is: ' key ', and the value is ' value;
	end;
quit;



*****************;
* Result tables *;
*****************;

* Create and view a result table *;
proc cas;
	* Create table structure *;
   	columnNames = {"Name", "Age", "Food"};
   	colTypes={"string", "integer", "string"};
   	result_table = newtable("My Table Name", columnNames, colTypes,
							{'Peter', 37, 'Gyros'}   
							{'Eva', 20, 'Muffins'},
							{'Owen', 37, 'Ice Cream'},
							{'Kristi', 20, 'Tacos'});
	

	* Print result table object and it's metadata *;
	print result_table;
	describe result_table;
quit;


* Filter a result table and save a result table as a SAS data set*;
proc cas;
	* Create table structure *;
   	columnNames = {"Name", "Age", "Food"};
   	colTypes={"string", "integer", "string"};
   	result_table = newtable("My Table Name", columnNames, colTypes,
							{'Peter', 37, 'Gyros'}   
							{'Eva', 20, 'Muffins'},
							{'Owen', 37, 'Ice Cream'},
							{'Kristi', 20, 'Tacos'});


	* Print subset of rows and columns of the table *;
	print (result_table            /* Result table */
		   .where(Age > 30)        /* Filter the table */
		   [,{'Name','Food'}]);    /* Select all rows and only the Name and Food columns */


	* Return a list from the column in the result table *;
	nameList = getcolumn(result_table,'Name');
	print nameList;
	describe nameList;

	* Save the result table as a SAS data set *;
	saveresult result_table dataout=work.myresulttable;
quit;

* Use traditional SAS programming on a SAS table *;
proc sgplot data=work.myresulttable;
	vbar Name / response=Age;
run;



**************************************************;
* Executing CAS actions                          *;
**************************************************;

* Execute and VIEW the results of a CAS action *;
proc cas;
	table.caslibInfo;
quit;


	



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
proc cas;
   columnNames = {"col1", "col2", "col3"};
   colTypes={"integer", "double", "string"};
   table = newtable("My Table Name", columnNames, colTypes);

   do i = 1 to 5;
	     z = (string)i;
	     do j = 1 to 5;
		      x = (string)j;
		      row = {i, 2.6 * j, "abc" || x || z};
		      addrow(table, row);
		    end;
   	end;
run;




**************************************************;
* Executing CAS actions                          *;
**************************************************;
proc cas;
	table.caslibInfo;
	



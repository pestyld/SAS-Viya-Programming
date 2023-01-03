**************************************************;
* Ask the Expert - CAS Language                  *;
**************************************************;

* ERROR - Execute CASL without a connection to CAS *;
proc cas;
	about;
quit;


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
	print 'My full name is : ' lastName || ', ' || firstName;
	print 'My full name is : ' cat(lastName,', ',firstName);
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
	languages = {'SAS', 'SQL', 'Python', 'CASL'};
	describe languages;
	print languages;
quit;


* Access elements in a list *;
proc cas;
	languages = {'element1', 'element2', 'element3', 'element4'};
	print languages[1];
quit;


proc cas;
	languages = {'SAS', 'SQL', 'Python', 'CASL'};
	print languages[1:3];
quit;


proc cas;
	languages = {'SAS', 'SQL', 'Python', 'CASL'};
	print languages[1:];
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
	do i over myInfo;
		print "Element: " i;
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


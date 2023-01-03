cas conn;

libname casuser cas caslib='casuser';

* create fake tables. One with char and one with varchar *;
data casuser.varchar;
	length col1 varchar(10);
 	col1='peter';
run;

data casuser.char;
	length col1 $5;
 	col1='owen';
run;

* View the CAS table metadata *;
proc cas;
	table.columnInfo / table='varchar';
	table.columnInfo / table='char';
quit;

* ERROR - issue with difference column data types *;
proc cas;
	table.append /
		source = 'varchar',
		target = 'char';
quit;


* take the char column, rename it, then create a duplicate column with varchar *;
data casuser.char;
	length col1 varchar(5);
	set casuser.char(rename=(col1=oldcol1));
	col1 = oldcol1;
	drop oldcol1;
run;


* View the new column data types *;
proc cas;
	table.columnInfo / table='varchar';
	table.columnInfo / table='char';
quit;
	

* Append the new CAS tables *;
proc cas;
	table.append /
		source = 'varchar',
		target = 'char';

	* preview the new table *;
	table.fetch / table='char';
quit;

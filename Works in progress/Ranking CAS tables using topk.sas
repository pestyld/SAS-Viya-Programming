cas conn;

* try and remove format and see waht happens with proc datasets *;
proc cas;
	table.fileInfo / caslib = 'samples';
	table.loadTable / 
		path='WATER_CLUSTER.sashdat', caslib='samples',
		casOut = {caslib='casuser', replace=TRUE};
	table.columnInfo / table={name='water_cluster', caslib='casuser'};
	table.fetch / 
		table={name='water_cluster', caslib='casuser', where='Daily_W_C_M3 > 0'}, 
		sortby={{name='Daily_W_C_M3', order='ascending'}};
quit;



* Comparing the raw parameter *;
proc cas;
	* Default - Raw=false *;
	simple.topK / 
		table={name='water_cluster', caslib='casuser'},
		inputs = 'Daily_W_C_M3',
		topk=5, 
		bottomk=5;

	* Set Raw=true *;
	simple.topK / 
		table={name='water_cluster', caslib='casuser'},
		inputs = 'Daily_W_C_M3',
		topk=5, 
		bottomk=5,
		raw=true;
quit;



proc cas;
	castbl = {name='water_cluster', caslib='casuser'};

	* total number of rows *;
	simple.numRows result = nr / table=castbl;
	totalRows = nr['numRows'];

	* rank the values *;
	simple.topK / 
		table=castbl,
		casout = {name='rank', caslib='casuser', replace=TRUE},
		inputs = 'Daily_W_C_M3',
		topk=totalRows, 
		bottomk=0,
		raw=True;

	* Preview the new table *;
	table.fetch / table={name='rank', caslib='casuser'};
quit;



proc cas;
	castbl = {name='water_cluster', caslib='casuser'};

	simple.numRows result = nr / table=castbl;
	totalRows = nr['numRows'];


	simple.topK / 
		table=castbl || {groupby = 'Weekend'} ,
		casout = {name='rank', caslib='casuser', replace=TRUE},
		inputs = 'Daily_W_C_M3',
		topk=totalRows, 
		bottomk=0,
		raw=True;

	* Preview the data *;
	table.fetch / table={name = 'RANK', where='Weekend=0'};
	table.fetch / table={name = 'RANK', where='Weekend=1'};
quit;
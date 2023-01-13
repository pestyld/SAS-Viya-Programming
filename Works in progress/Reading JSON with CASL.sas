proc cas;
	json_file = '/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/temp.json';
	x=json2casl(readpath(json_file));
	describe x;
	print "******************";
	print getkeys(x);
/* 	print x['Nested object sample']; */
	
quit;
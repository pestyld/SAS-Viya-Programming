proc cas;
	dict = {key='test', 
            other = {'a','c'}};
	print dict;

	tojson = casl2json(dict);
	print tojson;

	file outjson "/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/test.json";
	print tojson;
quit;

proc cas;
	dict = {key='test', 
            other = {'a','c'}};
	print dict;

	tojson = casl2json(dict);
	print tojson;

	file outjson "/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/test.json";
	print tojson;
quit;
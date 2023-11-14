data test;
	call streaminit(1);
	do i = 1 to 10;
		month = rand('uniform',1,12);
		day = rand('uniform',1,28);
		year = rand('uniform', 2020,2024);
		date = mdy(month, day, year);
		hour = rand('uniform', 1, 24);
		minute = rand('uniform', 1, 60);
		second = rand('uniform', 1, 60);
		DATE_DATE9 = date;
		DATE_MMDDYY = date;
		DATE_DDMMYY = date;
		DATE_MONYY = date;
		DATETIME_raw = DHMS(mdy(month,day,year), hour, minute, second);
		DATETIME = DATETIME_raw;
		DATETIME_AMPM = DATETIME_raw;
		DATETIME_MDY = DATETIME_raw;
		output;
	end;
	format DATE_DATE9 DATE9.
		   DATE_MMDDYY mmddyy10.
           DATE_DDMMYY ddmmyy10.
		   DATE_MONYY monyy.
           DATETIME datetime.
		   DATETIME_AMPM dateampm.
		   DATETIME_MDY mdyampm.
	;
	drop month day year date i hour minute second DATETIME_raw;
run;
proc print data=test;
run;
proc export data=test outfile="/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/SAS Viya Programming/Working with Date, Time and Datetime Columns/test.csv" dbms=csv;
run;

proc import datafile="/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/SAS Viya Programming/Working with Date, Time and Datetime Columns/test.csv"
	dbms=csv out=testcsv;
run;
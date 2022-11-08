/* data casuser.test;  */
/*     call streaminit(10); */
/*     do i=1 to 12; */
/*         do y=2020 to 2021; */
/*             date=mdy(i,1,y); */
/*             total=round(rand("uniform",1,10)); */
/*             output; */
/*         end; */
/*     end; */
/*     format date monyy7.; */
/*     drop i y; */
/* run; */
/*  */
cas conn;
libname casuser cas caslib='casuser';

data casuser.test; 
    call streaminit(10);
    do i=1 to 20000;
            Year = round(rand('uniform',2020,2021));
            month=round(rand('uniform',1,12));
            day=round(rand('uniform',1,28));
            date=mdy(month,day,Year);
            total=round(rand("uniform",1,10));
            output;
    end;
    format date date9.;
    drop i month day year;
run;
proc print data=casuser.test(obs=25);
run;



**************************;
*Get a sum by each month *;
**************************;
proc cas;
	tbl = {name='test', caslib='casuser'};
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        Interval="Month",
        casOut={name="month_summary",caslib="casuser", replace=TRUE};

    table.fetch / table={name="month_summary",caslib="casuser"}, index=FALSE, to=500, sortby="Date";
quit;

**************************;
*Get a sum by each month  +OFFSET *;
**************************;
proc cas;
	tbl = {name='test', caslib='casuser'};
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"},
            {name='Total', agg="MAX"}
        },
        ID="Date",
		offset=-1,
        Interval="MONTH",
        casOut={name="month_sum",caslib="casuser", replace=TRUE};

    table.fetch / table={name="month_sum",caslib="casuser"}, index=FALSE, to=500, sortby='Date';
quit;




**************************;
*Get a sum by each qtr   *;
**************************;
proc cas;
	tbl = {name='test', caslib='casuser'};
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"},
            {name='Total', agg="MAX"}
        },
        ID="Date",
        Interval="QTR",
        casOut={name="qtr_summary",caslib="casuser", replace=TRUE};

    table.fetch / table={name="qtr_summary",caslib="casuser"}, index=FALSE, to=500, sortby='Date';
quit;



**************************;
*Get a sum by each year  *;
**************************;
proc cas;
	tbl = {name='test', caslib='casuser'};
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        Interval="YEAR",
        casOut={name="year_summary",caslib="casuser", replace=TRUE};

    table.fetch / table={name="year_summary",caslib="casuser"}, index=FALSE, to=500;
quit;



******************************;
* WINDOWINT PARAMETER???        *;
******************************;
proc cas;
	tbl = {name='test', caslib='casuser'};

*Rolling sum for the last 3 months *;
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        Interval="MONTH",
        windowInt="Year",
        casOut={name="rolling",caslib="casuser", replace=TRUE};

    table.fetch / table={name="rolling",caslib="casuser"}, index=FALSE, to=500, sortby='Date';
quit;


proc cas;
	tbl = {name='test', caslib='casuser'};

*Rolling sum for the last 3 months *;
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        subInterval="Year",
        Interval="Month",
        casOut={name="rolling",caslib="casuser", replace=TRUE};

    table.fetch / table={name="rolling",caslib="casuser"}, index=FALSE, to=500, sortby='Date';
quit;
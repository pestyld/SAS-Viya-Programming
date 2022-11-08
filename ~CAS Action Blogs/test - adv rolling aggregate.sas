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
    do i=1 to 10000;
            Year = round(rand('uniform',2020,2022));
            month=round(rand('uniform',1,12));
            day=round(rand('uniform',1,28));
            date=mdy(month,day,Year);
            total=round(rand("uniform",1,10));
            output;
    end;
    format date date9.;
    drop i month day year;
run;




proc cas;
*preview the raw data *;
    tbl={name="test",caslib="casuser"};
    table.fetch / 
        table=tbl;

**************************;
*Get a sum by each month *;
**************************;
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        Interval="Month",
        casOut={name="month_summary",caslib="casuser", replace=TRUE};

    table.fetch / table={name="month_summary",caslib="casuser"}, index=FALSE, to=500;


**************************;
*Get a sum by each qtr   *;
**************************;
    aggregation.aggregate /
        table=tbl || {groupBy="Date"},
        varSpecs={
            {name="Total",subset="SUM"}
        },
        ID="Date",
        Interval="QTR",
        casOut={name="qtr_summary",caslib="casuser", replace=TRUE};

    table.fetch / table={name="qtr_summary",caslib="casuser"}, index=FALSE, to=500;

**************************;
*Get a sum by each year  *;
**************************;
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
* WINDOWINT PARAMETER        *;
******************************;
proc cas;
    tbl={name="test",caslib="casuser"};
    table.fetch / 
        table=tbl;

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

    table.fetch / table={name="rolling",caslib="casuser"}, index=FALSE, to=500;
quit;
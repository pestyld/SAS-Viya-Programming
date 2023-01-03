* Specify a location for your output files. Otherwise delete the ODS statement below *;
%let homedir=%sysget(HOME);
%let path=&homedir/SAS Viya/CASL Code/Using columns with special characters in actions;
%put &=path;

cas conn;
libname casuser cas caslib='casuser';

* Create a test CAS table with columns that contains a special characters*;
data casuser.example;
    "myname's"n = 100;
    "other special @"n = 200;
    output;
run;
    

* To use a column with an apostrophe within a the runCode action in CASL use the source block *;
proc cas;
    source ds;
        data casuser.example_final;
            set casuser.example;
            new = "myname's"n / 2;
            fixColName="myname's"n;
        run;
    endsource;

    dataStep.runCode /
        code=ds;
quit;


ods html5 file="&path./results_reference_special_column_in_list.html";
proc cas;

* Preview the table *;
    table.fetch / table={name='example_final', caslib='casuser'};

* To reference a column in a parameter to analyze, you should be able to just   *;
* surround it in quotations without the name literal.                           *; 
    table.fetch / 
        table={name='example_final', caslib='casuser'},
        fetchVars = {'fixColName', "myname's", "other special @"};
quit;
ods html5 close;

* Create a new column using a column with special characters in computedVarsProgram *;
ods html5 file="&path./results_reference_special_column_in_computedVarsProgram.html";
proc cas;

    *Key is to use a source block with a name literal *;
    source cre8Col;
        createColumn="other special @"n * 100;
    endsource;

    * Create a column based on a column with special characters *;
    table.fetch / 
        table={name='example_final', 
               caslib='casuser',
               computedVarsProgram = cre8Col
        }
        fetchVars = {'fixColName', "myname's", "other special @",'createColumn'};
quit;
ods html5 close;





* Using FEDSQL with special column names *;
data casuser.example;
    "myname's"n = 100;
    "other special @"n = 200;
    output;
    "myname's"n = 1000;
    "other special @"n = 2000;
    output;
run;

proc cas;
    source q;
        select * 
        from casuser.example
    endsource;
    fedSQL.execDirect / query=q;

* Select special columns *;
    source sel_special_cols;
        select "myname's","other special @"
        from casuser.example
    endsource;
    fedSQL.execDirect / query=sel_special_cols;

* Filter special columns *;
    source filter_special_cols;
        select "myname's","other special @"
        from casuser.example
        where "myname's"=100
    endsource;
    fedSQL.execDirect / query=filter_special_cols;
quit;
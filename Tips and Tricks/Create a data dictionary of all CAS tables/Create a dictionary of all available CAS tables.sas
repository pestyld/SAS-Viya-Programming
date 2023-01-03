* Specify a location for your output files *;
%let homedir=%sysget(HOME);
%let path=&homedir/SAS Viya/CASL Code/Create a data dictionary of all CAS tables;


cas conn;

proc cas;

* Create the table structure *;
    * Column names *;
    newCols = {"Caslib", "Description", "Path", "TableName", "NRows", "NCols"};
    * Column data types *;
    newColTypes = {"varchar", "varchar", "varchar", "varchar", "int32", "int32"};
    * Create the table *;
    tbl = newTable("CASTableInfo", newCols, newColTypes);


* Find all available caslibs and store the results in the variable caslibDict*;
    table.caslibInfo result=caslibDict;

    
    caslibTbl = caslibDict.CaslibInfo;
    *caslibTbl = caslibDict.CaslibInfo.where(Name in {'ACADEMIC', 'Public'});
    

* Loop over each available caslib and reference the caslib name in the tableInfo action to view all 
  in-memory tables. Then add the available in-memory tables to the new table object *;
    do caslib over caslibTbl;
       
    * Find available in-memory tables in each caslib. Store the results *;
        table.tableInfo result=tblList / caslib=caslib.Name;

        * Check to see if a key exists in the result of the tableInfo action for that caslib. If it does
          Loop over each in-memory table and store the details in my table tbl  *;
        if exists(tblList,"TableInfo") = 1 then 
            do casTable over tblList.tableInfo;
                 addrow(tbl, {caslib.Name, caslib.Description, caslib.Path,     /* Caslib informatoin */
                              casTable.Name, casTable.Rows, casTable.Columns}); /* In-memory table information */
            end;
        else print "-------------- No in-memory tables found in: " caslib.Name " --------------"; 
    end;

* Save the result table to a SAS data set *;
    saveresult tbl dataout=work.CASTableInfo replace;

* Save the result table to a CSV file *;
    saveresult tbl csv="&path/available_tables_dictionary.csv" replace;
quit;


* View the data dictionary of CAS tables *;
proc print data=work.CASTableInfo(obs=10) noobs;
run;

* Export the SAS data set to Excel *;
proc export data=work.castableinfo 
            dbms=xlsx
            outfile="&path/available_tables_dictionary.xlsx"
            replace;
quit;


* Visualize the data *;
%let txtColor = gray;
%let axesLabelSize=12pt;

ods listing gpath="&path"; 
ods graphics / width=10in imagename='TotalTablesByCaslib' outputfmt=jpeg;

title justify=left height=16pt color=&txtColor "TOTAL NUMBER OF TABLES IN EACH CASLIB";
proc sgplot data=work.CASTableInfo noborder;
    vbar caslib / 
        categoryorder=respdesc
        nooutline
        fillattrs=(color=dodgerblue);
    yaxis label="Number of Tables" 
          labelattrs=(color=&txtColor size=&axesLabelSize)
          valueattrs=(color=&txtColor);
    xaxis label="Caslib Name" 
          labelattrs=(color=&txtColor size=&axesLabelSize) 
          valueattrs=(color=&txtColor);
run;
title;
ods graphics / reset;

*******************************************************************;
* PROGRAM: Create a user defined action set                       *;
* DESCRIPTION:  Create your own use defined actions to share with *;
*               the team.                                         *;
*******************************************************************;

* Load the CARS and AIR tables into CAS *;
cas conn;
libname casuser cas caslib='casuser';

data casuser.cars(promote=yes);
    set sashelp.cars;
run;

data casuser.air(promote=yes);
    set sashelp.air;
run;

* Confirm the cars table is in-memory *;
proc cas;
    table.tableInfo / caslib="casuser";
quit;



*****;
* 1 *;
*****;
****************************************************;
* Basic program you always run to explore data:    *;
* - Obtains table information (rows and columns)   *;
* - Column metadata                                *;
* - First 20 rows                                  *;
* - Number of distinct values for each column      *;
****************************************************;
proc cas;
    casTbl={name="cars", caslib="casuser"};

* Table information *;
    table.tableInfo result=ti / caslib=casTbl.caslib, table=casTbl.name;
    info=ti.tableInfo.compute('Caslib',upcase(casTbl.caslib))[,{'Name','Caslib','Rows','Columns'}];
    print info;

* Column information *;
    table.columnInfo / table=casTbl;

* First 20 rows *;
    table.fetch / table=casTbl, index=FALSE;

* Distinct values *;
    simple.distinct / table=casTbl;
quit;



*****;
* 2 *;
*****;
*******************************************;
* Create a user defined action set        *;
* - Action set name: teamActions          *;
* - Single action named: basicExplore     *;
*******************************************;
proc cas;
    builtins.defineActionSet / 
       name="teamActions", 
       label="Company Specific Actions",

/*Can a user defined action */

       actions={

       /*Basic explore action*/
           {
            name="basicExplore",
            desc="View the number of rows and columns, column metadata, first 20 rows, and number of distinct values.",
            parms={
                   {name="tbl", type="string", required=TRUE, desc="Specify the CAS table"},
                   {name="lib", type="string", required=TRUE, desc="Specify the Caslib"}
            }
            definition="
                   /* Use the parameters to reference the CAS table */
                        x={name=tbl, caslib=lib};
                   
                   /* Number of rows and columns in the CAS table */
                        table.tableInfo result=ti / caslib=x.caslib, table=x.name;
                        info=ti.tableInfo.compute('Caslib',upcase(x.caslib))[,{'Name','Caslib','Rows','Columns'}];     
                        /* Store info table in a dictionary named td, with the key TaleInformation */
                        td.TableInformation=info;
                        send_response(td);
                         
                   /* Print the column metadata */
                        table.columnInfo result=ci / table=x;
                        send_response(ci);  
               
                   /* View the first 20 rows */
                        table.fetch result=tblPreview / 
                             table=x,
                             index=FALSE;
                        send_response(tblPreview);

                   /* View the number of distinct values in each column */
                        simple.distinct result=d / table=x;
                        send_response(d);
                       "
            }

/*End user action set*/        
       };  
quit;


* Confirm the action set was created *;
proc cas;
    builtins.actionsetInfo;
quit;


* Use the user defined action set *;
proc cas;
* CARS TABLE *;
    teamActions.basicExplore result=x / tbl="cars", lib="casuser";
    describe x;
* AIR TABLE *;
    teamActions.basicExplore / tbl="air", lib="casuser";
quit;
    


*****;
* 3 *;
*****;
*************************************************************;
* Save the user defined action set for others on your team. *; 
* 1. You must save it as a CAS table.                       *;
* 2. Save the CAS table as a data source sashdat file in a  *;
*    caslib. To share with others the caslib must be        *;
*    accessible by your team.                               *;
*************************************************************;
proc cas;

* Convert the action set to a CAS table *;
    builtins.actionSetToTable /
        actionSet="teamActions",
        casOut={name="teamActions", 
                caslib="casuser", 
                replace=TRUE};

* Save the CAS table as a data source file that can be reference by others *;
    table.save /
        table={name="teamActions", caslib="casuser"},
        name="teamActions.sashdat", caslib="casuser", replace=TRUE;

* Confirm the data source file was saved by viewing the caslib *;
    table.fileInfo / caslib="casuser";
quit;     



****************************************;
* 4 - Load the user defined action set *;
****************************************;

* Disconnect from CAS (clears all session tables)*;
cas conn terminate;

* Connect to CAS *;
cas conn;

* Confirm the CARS and AIR table are in-memory *;
* View available action sets. Notice the user defined action set is not available *;
proc cas;
    table.tableInfo / caslib="casuser";

* View available action sets *;
    builtins.actionsetInfo;
quit;



*****;
* 5 *;
*****;
************************************************************;
* Load the user defined action set                         *;
************************************************************;
proc cas;
* Load the user defined action set *;
    builtins.actionSetFromTable /
        table="teamActions.sashdat";

* View available action sets *;
    builtins.actionSetInfo;
    
* Use the user defined action set *;
    basicExplore / tbl="cars", lib="casuser";
run;



*****;
* 6 *;
*****;
************************************************************;
* Clean up:                                                *;
* 1. Drop the promoted tables (CARS and AIR)               *;
* 2. Terminate the CAS connection                          *;
************************************************************;
proc cas;
    tables={"cars", "air"};
    do i over tables;
        table.dropTable /
            caslib="casuser",
            name=i,
            quiet=TRUE;
    end;
    table.deletesource / 
           caslib='casuser', 
           source='teamActions.sashdat', 
           quiet=TRUE;
quit;

cas conn terminate;
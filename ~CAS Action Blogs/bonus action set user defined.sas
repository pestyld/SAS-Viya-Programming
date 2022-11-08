

***********;
* 5 - BONUS PROGRAM*;
*****;
* separate program to share with audience *; * give description below *;
************************************************************;
* Go big or go home!                                       *;
* The following actions are created:                       *;
* - basicExplore                                           *;
* - pctDistinct                                            *;
* - catFreq                                                *;
************************************************************;
proc cas;

***********************;
* basicExplore action *;
***********************;
    source basicExplore;
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
    endsource; 

***********************;
* pctDistinct action  *;
***********************;
    source pctDistinct;
        /* Use the parameters to reference the CAS table */
           x={name=tbl, caslib=lib};

        /* Find the total number of rows in the CAS table */
           simple.numRows result=nr / table={name=x.name, caslib=x.caslib};

        /* Find the total number of distinct values in a CAS table. Then divide by number of rows */
           simple.distinct result=d / table={name=x.name, caslib=x.caslib};
           pctDistinct=d.Distinct.compute({'PctDistinct',percent7.2}, NDistinct/nr.numRows)[,{'Column','NDistinct','PctDistinct'}];
           pctDistinct=sort_rev(pctDistinct,'NDistinct');
           pd.PercentDistinct=pctDistinct;
           send_response(pd);
    endsource;


***********************;
* catFreq action      *;
***********************;
    source catFreq;
        x={name=tbl, caslib=lib};

      /* Find all columns where percent of distinct values is less than the amount specified */
        teamActions.pctDistinct result=pctd / tbl=x.name , lib=x.caslib;
        colNames=pctd.PercentDistinct.where(pctDistinct < percentDistinct)[,"Column"];

      /* Execute the freq action on the columns stored from the previous action */
        simple.freq result=ft / table={name="cars", caslib="casuser"}, inputs=colNames;

      /* Create an information table that includes percentDistinct specified and number of columns analyzed */
        cols={name={"SpecifiedPercentage","NumberOfColsAnalyzed"}, type={"double","int32"}};
        

        specValue=newtable("SpecInformation", cols.name, cols.type, {percentDistinct, dim(colNames)});
        oneway.userSpec=specValue;    

        oneway.freqs=ft.Frequency; 

        send_response(oneway);
    endsource;



***********************;
* Create action set   *;
***********************;
    builtins.defineActionSet / 
       name="teamActions"

/*Can a user defined actions*/
       actions={

       /*1. Basic explore action*/
           {
            name="basicExplore",
            desc="View the number of rows and columns, column metdata, first 20 rows, and number of distinct values.",
            parms={
                   {name="tbl", type="string", required=TRUE, desc="Specify the CAS table"},
                   {name="lib", type="string", required=TRUE, desc="Specify the Caslib"}
            },
            definition=basicExplore
            },

       /*2. Calculating percent distinct */
           {
            name="pctDistinct",
            desc="View the percentage of distinct values in each column.",
            parms={
                   {name="tbl", type="string", required=TRUE, desc="Specify the CAS table"},
                   {name="lib", type="string", required=TRUE, desc="Specify the Caslib"}
            },
            definition=pctDistinct
            },

       /*3. One-way frequency table for columns less than x percent distinct */
           {
            name="catFreq",
            desc="Create a single result table with a one-way frequency for all columns less than specified percent distinct.",
            parms={
                   {name="tbl", type="string", required=TRUE, desc="Specify the CAS table"},
                   {name="lib", type="string", required=TRUE, desc="Specify the Caslib"},
                   {name="percentDistinct", type="DOUBLE", defaultDouble=.1, maxDouble=1, minDouble=0} 
            },
            definition=catFreq
            }

/*End user action set*/        
       };  
quit;

proc cas;
    teamActions.catFreq / tbl="cars", lib="casuser";
    teamActions.catFreq / tbl="cars", lib="casuser", percentDistinct=.05;

    teamActions.basicExplore / tbl="cars", lib="casuser";

    teamActions.pctDistinct / tbl="cars", lib="casuser";
quit;

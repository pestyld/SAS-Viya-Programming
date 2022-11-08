cas conn;

libname casuser cas caslib='casuser';

* Create a test cars table *;
data casuser.cars_test;
    set sashelp.cars;
run;

/* 
What a Common Table Expression (CTE) would look like in SAS Viya in CAS. 
SAS does not have the concept CTEs, so this part will not run in SAS.

create CTE:

with Origin_distinct (Origin, testCol) AS
(
select distinct Origin, 1 as testCol
    from casuser.cars;
)

Use the CTE in a query to join the CTE from above:

select m.Make, m.Model,m.Origin, cte.testCol
   from casuser.cars as m inner join (:cte:) as cte
   on m.Origin = cte.Origin;

*/
proc cas;
* - Just create a CAS table from the CTE above. Remember, CAS always works in memory when processing data. *;
* - Creating a session scope table of the CTE will delete it when disconnecting from CAS You can also drop it manually if you want *;
* - Name the CAS table the name of the CTE *;   
     source cte_query;
        create table casuser.origin_distinct{options replace=True} as
        select distinct Origin, 1 as testCol
            from casuser.cars;
    endsource;
    fedSQL.execDirect / query = cte_query;


    source main_query1;
        select m.Make, m.Model,m.Origin, cte.testCol
            from casuser.cars as m inner join casuser.origin_distinct as cte
            on m.Origin = cte.Origin
            limit 10;
    endsource;
    fedSQL.execDirect / query = main_query1;


    source main_query2;
        select m.Make, m.Model,m.Origin, cte.testCol
            from casuser.cars as m inner join casuser.origin_distinct as cte
            on m.Origin = cte.Origin
            limit 5;
    endsource;
    fedSQL.execDirect / query = main_query2;


    * If you want to drop the in-memory table manually use table.dropTable *;
    table.dropTable / name='origin_distinct', caslib='casuser', quiet=TRUE;
quit;


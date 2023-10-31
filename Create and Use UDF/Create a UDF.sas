/***********************************************/
/* CREATE CAS USER DEFINED FUNCTION (UDF)      */
/***********************************************/

/*********************************/
/* Confirm CAS session is active */
/* If not, create CAS sesssion   */
/*********************************/
%let cas_session_exists= %sysfunc(sessfound(&_CASNAME_));
%if &cas_session_exists=0 %then %do; 
	cas conn;
%end;
%else %do;
	%put NOTE:CAS session &_CASNAME_ already active;
%end;

/*****************************************/
/* Create a libref to the Casuser caslib */
/*****************************************/
libname casuser cas caslib='casuser';


/*****************************/
/* Create the test CAS table */
/*****************************/
data casuser.tempdata;
	do Temp = 'HighTemp = 83; LowTemp = 55;',
			  'HighTemp = 86; LowTemp = 59;',
              'HighTemp = 92; LowTemp = 63;',
              'HighTemp = 91; LowTemp = 65;',
              'HighTemp = 80; LowTemp = 51;';
		output;
	end;
run; 

/* Preview the CAS table */
proc print data=casuser.tempdata(obs=5);
run;



/***********************************/
/* Create a UDF for the CAS server */
/***********************************/
/* FCMP Action Set: https://go.documentation.sas.com/doc/en/pgmsascdc/default/caspg/cas-fcmpact-TblOfActions.htm */
proc cas;

	/* The subroutine code to create the get_temp_value UDF */
	source get_temp_value_func;
	    function get_temp_value(colname $, position);
	        
	        /* Get the statement by position */
	        get_statement_from_position = scan(colname, position,';');
	        
	        /* Get the number from the string */
	        get_number_as_string = scan(get_statement_from_position, -1, ' ');
	        
	        /* Get the number from the statement and convert to a numeric column */
	        convert_string_to_numeric = input(get_number_as_string, 8.);
	        
	        /* Return numeric value */
	        return(convert_string_to_numeric);
	        
	    endsub;
	endsource;

	/* The subroutine code to create the f_to_C UDF */
	source f_to_c_func;
	    function f_to_c(f_temp);
	        
	        /* Convert the Fahrenheit temp to Celsius */
	        c_temp = round((f_temp - 32) * (5/9));
	        
	        /* Return celsius value */
	        return(c_temp);
	        
	    endsub;
	endsource;

	/* Create the UDFs */
	fcmpact.addRoutines /
		routineCode = cats(get_temp_value_func,f_to_c_func),  /* Concat the two string variables with the function code */
        saveTable = True,                                     /* Save the table as a source file */
        funcTable = {name = "my_udfs_sas",                    /* Create the CAS table */
					 caslib = 'casuser',
					 replace = TRUE},
        appendTable = True;                                   /* Append the functions to the table if it already exists */
quit;

/* View the CAS table and source file */
proc casutil incaslib = 'casuser';
	list tables;
	list files;
quit;


/* Load the MY_UDFS file into memory to make the function definitions available if the table is not loaded. */
proc cas;
	fcmpact.loadFcmpTable / 
		table='MY_UDFS_SAS.sashdat', 
		caslib = 'casuser';
quit;



/* Modify the cmplib option for the CAS and Compute servers to use the function CAS table */
options sessopts=(cmplib='casuser.my_udfs_sas')  cmplib=(casuser.my_udfs_sas);



/* Use the function on the CAS table to run in the CAS cluster */
data casuser.final_sas;
    set casuser.tempdata;
    HighTempF = get_temp_value(Temp,1);
    LowTempF = get_temp_value(Temp,2);
    HighTempCelsius = f_to_c(HighTempF);
    LowTempCelsius = f_to_c(LowTempF);
run;

/* Preview the clean data */
proc print data=casuser.final_sas(obs=5);
run;
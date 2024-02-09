/***********************************************************/
/* This code uses a function that was created by Python    */
/***********************************************************/

/* Create CAS session */
cas conn;

/* Create a libref to the Casuser caslib */
libname casuser cas caslib='casuser';

/* Create the test CAS table */
data casuser.tempdata;
Temp = 'HighTemp = 83; LowTemp = 55;';
output;
Temp = 'HighTemp = 86; LowTemp = 59;';
output;
Temp = 'HighTemp = 92; LowTemp = 63;';
output;
Temp = 'HighTemp = 91; LowTemp = 65;';
output;
Temp = 'HighTemp = 80; LowTemp = 51;';
output;
run; 

/* Load the MY_UDFS file into memory to make the function definitions available */
proc cas;
	fcmpact.loadFcmpTable / 
		table='MY_UDFS.sashdat', 
		caslib = 'casuser';
quit;

/* Modify the cmplib option to use the CAS table */
options sessopts=(cmplib='casuser.my_udfs') cmplib=(casuser.my_udfs);

/* Use the function in the SAS data set to run in the CAS cluster */
data casuser.final_sas / sessref=conn;
    set casuser.tempdata;
    HighTempF = get_temp_value(Temp,1);
    LowTempF = get_temp_value(Temp,2);
    HighTempCelsius = f_to_c(HighTempF);
    LowTempCelsius = f_to_c(LowTempF);
run;

/* Preview the final CAS table */
proc print data=casuser.final_sas(obs=5);
run;
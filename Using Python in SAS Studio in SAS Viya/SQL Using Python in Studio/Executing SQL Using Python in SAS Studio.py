###########################################################
## Executing SQL in SAS Viya Using Python in SAS Studio  ##
###########################################################


#############################
## SAS COMPUTE SERVER SQL  ##
#############################

## NOTES:
## - Must use PROC SQL or PROC FEDSQL
## - PROC SQL works on traditional SAS libraries (not caslibs)
## - Each query within PROC SQL must end in a semi-colon
## - You can use PROC SQL enhancements
## - PROC SQL supports implicit and explicit pass through into databases (functionality depends on the database)
## 		a. Implicit pass through will convert SAS SQL into native database SQL where possible for in-database processing
##	    b. Explicit pass through enables you to use native database SQL through SAS


## Simple SQL query
sas_data = 'sashelp.cars'

sqlQuery = f'''
proc sql;
	select Make, count(*) as TotalCars
		from {sas_data}
		group by Make
		order by TotalCars desc;
quit;
'''
SAS.submit(sqlQuery)



## PROC SQL enhancements (calculated keyword) to create a table
sqlQuery = f'''
proc sql;

/* Create table query */
	create table high_avg_mpg as
	select Make, 
           Model, 
           mean(MPG_City,MPG_Highway) as MPG_Avg
		from {sas_data}
		where calculated MPG_Avg > 40;

/* Preview query */
	select *
		from work.high_avg_mpg;
quit;
'''
SAS.submit(sqlQuery)


## Read the SAS table as a DataFrame
df = SAS.sd2df('work.high_avg_mpg')

print(type(df))
print(df.head())



######################
## CAS SERVER SQL   ##
######################

## NOTES:
## - Must use FedSQL (PROC FEDSQL or the fedSQL.execDirect action)
## - FedSQL works on caslibs
## - FedSQL runs on the CAS cluster for MPP
## - FedSQL is a vendor neutral, ANSI 1999 SQL implementation. No PROC SQL enhancements.
## - Each query within PROC FEDSQL must end in a semi-colon
## - FedSQL supports implicit and explicit pass through into databases (functionality depends on the database)
## 		a. Implicit pass through will convert SAS SQL into native database FedSQL where possible for in-database processing
##	    b. Explicit pass through enables you to use native database SQL through SAS


##
## SIMPLE PROC FEDSQL QUERY
##

## Specify the caslib name and CAS table. Must be the actual caslib name, not the libref to a caslib
tbl = 'casuser.cars'

## Specify the name of the CAS session
cas_session_name = 'conn'

## The SESSREF= option specifies the CAS session and runs the SQL query in the CAS cluster. 
## The caslib name must be specified here. You cannot use the libref to a caslib.
sqlQuery = f'''
proc fedsql sessref={cas_session_name};
	select Make, count(*) as TotalCars
		from {tbl}
		group by Make
		order by TotalCars desc;
quit;
'''
SAS.submit(sqlQuery)



##
## USE THE SWAT PACKAGE TO EXECUTE THE FEDSQL.EXECDIRECT ACTION
##

## NOTE: This is doing the exact same thing as PROC FEDSQL. 
##       The main difference is you are using Python and the execDirect method (action) directly.

## Import packages
import swat
import os

## Add certificate location to operating system's list of trusted certs.
os.environ['CAS_CLIENT_SSL_CA_LIST']=os.environ['SSLCALISTLOC']

## Connect to the CAS server for distributed processing
conn = swat.CAS(hostname="sas-cas-server-default-client",port=5570, password=os.environ['SAS_SERVICES_TOKEN'])

## View the version of Viya and confirm the connection works
print(conn.about()['About']['Viya Version'])

## Load the fedSQL action set (package)
conn.loadActionSet('fedSQL')

## SQL query as a string. 
## Only one query can be executed at a time. 
## Must specify the caslib name followed by the CAS table name.

myQuery = '''
select Make, count(*) as TotalCars
	from casuser.cars
	group by Make
'''

## Execute the FEDSQL action. Store the results in the dictionary object that contains the DataFrame on the client.
cr = conn.execDirect(query = myQuery)

## Print the object type (dictionary)
print(type(cr))

## Print the keys (Result Set)
print(cr.keys())

## Print the DataFrame in the dictionary
df = cr['Result Set']
print(type(df))
print(df)

## Terminate the CAS connection
conn.terminate()
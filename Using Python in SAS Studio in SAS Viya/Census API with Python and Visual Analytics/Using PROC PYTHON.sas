****************************************************************;
* - Read the Census API Using the Python Requests Package      *;
* - Store the results as a SAS data set in the WORK library    *;
****************************************************************;
proc python;
submit;

#############################################################################
## READ DATA FROM AN API AND LOAD IT TO THE CAS SERVER FOR VISUALIZATION   ##
#############################################################################


import requests
import os
import swat
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

## Options
pd.set_option('display.max_columns', 40)



#################################
## REQUEST TO THE CENSUS API   ##
#################################

# Parameters for the get request
parameters = {'get' : 'DENSITY_2021,POP_2021,NAME,NPOPCHG_2021',
              'for' : 'state'}

# Census API URL
census_url = 'https://api.census.gov/data/2021/pep/population?'

# Send the get request
data = requests.get(census_url, params = parameters, timeout = 5)
print(data)
print(data.content)


#############################################################################
## CREATE A DATAFRAME WITH THE JSON FILE USING THE USER DEFINED FUNCTION   ##
#############################################################################


## CLEAN JSON DATA FUNCTION 
def createData(_censusJSON):
    
    # Obtain column names from the JSON file in the first row
    pop_data_col_names = _censusJSON.json()[0]
    
    # Make column names lowercase
    pop_data_col_names = [x.lower() for x in pop_data_col_names]
    
    # Obtain data from the JSON file. First row is headers
    pop_data = _censusJSON.json()[1:]
    
    # Create the dataframe and add the rows and columns
    df = pd.DataFrame(data = pop_data, columns = pop_data_col_names)
    
    # Finalize and return the dataframe
    return (df
            .astype({'density_2021':'float',
                     'pop_2021':'int64',
                     'npopchg_2021':'int64'})
            .assign(
                population_pct_2021 = lambda _df: _df.pop_2021 / _df.pop_2021.sum()
                   )
    )


df = createData(data)
print(df.head())



#############################################################################
## SEND THE DATAFRAME TO EITHER THE SAS COMPUTE SERVER, OR THE CAS SERVER  ##
#############################################################################
## NOTE: Examples below use the SAS callback methods. Might require some   ##
##       some SAS code if you are loading to CAS.                          ##
#############################################################################

# Send the data to the Compute server
SAS.df2sd(df, 'work.population2021_sas_compute')


##
## Send the data to the CAS server and promote the table to use SAS Visual Analytics
##

## Drop the table if it already exists
dropTable = '''
proc casutil;
	droptable casdata="pop2021_python_editor" incaslib="casuser" quiet;
quit;
'''
SAS.submit(dropTable)

## Load and promote the table to CAS
SAS.df2sd(df, 'casuser.pop2021_PROC_PYTHON(PROMOTE=YES)')

endsubmit;
quit;

******************************************************************;
* PREPARE THE DATA FOR SAS VISUAL ANALYTICS USING SAS            *;
******************************************************************;

*******************************************************************;
* 1. Calculate the Total Population and Store as a Macro Variable *;
*******************************************************************;
proc sql;
	select sum(pop_2021) format=16.
		into :TotalPopulation
		from work.population2021_sas_compute;
quit;
%put &=TotalPopulation;


****************************************************************;
* 2. Prepare the table using the DATA step                     *;
****************************************************************;
data work.population_final_sas_compute;
	set work.population2021_sas_compute;

* Find the population percentage for each state *;
	population_pct_2021 = pop_2021 / &TotalPopulation;

* Format columns *;
	format population_pct_2021 percent8.2 pop_2021 npopchg_2021 comma16.;
run;


****************************************************************;
* 3. Preview the table and table data types                    *;
****************************************************************;
proc contents data=work.population_final_sas_compute;
run;

proc print data=work.population_final_sas_compute(obs=10);
run;


****************************************************************;
* 4. Plot the data using SGPLOT                                *;
****************************************************************;
%let txtColor = gray;

ods graphics / height=7.5in;
title height = 14pt color = &txtColor justify=left "Total Population Percentage by State";

proc sgplot data=population_final_sas_compute
			noborder nowall;
	vbar Name / 
		response = population_pct_2021
		categoryorder = respdesc
		datalabel
		datalabelattrs=(color = &txtColor size=9pt);
	yaxis display=none;
	xaxis display = (nolabel);
	format population_pct_2021 percent7.1;
quit;

title;
ods graphics / reset;

********************************************************************;
* 5. Load the table to the CAS server to use SAS Visual Analytics  *;
********************************************************************;
proc casutil;
	load data=work.population_final_sas_compute 
		 outcaslib='casuser' 
         casout='US_population_SAS'
         promote;
quit;

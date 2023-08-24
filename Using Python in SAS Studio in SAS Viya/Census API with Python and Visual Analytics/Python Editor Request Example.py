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
SAS.df2sd(df, 'work.pop2021_python_editor')


##
## Send the data to the CAS server and promote the table to use SAS Visual Analytics
##

## Drop the table if it already exists
dropTable = '''
proc casutil;
	droptable casdata='pop2021_python_editor' incaslib='casuser' quiet;
quit;
'''
SAS.submit(dropTable)

## Load and promote the table to CAS
SAS.df2sd(df, 'casuser.pop2021_python_editor(PROMOTE=YES)')



####################################################################
## USE THE SWAT PACKAGE TO LOAD THE DATAFRAME TO THE CAS SERVER   ##
####################################################################
## NOTE: This avoids using any SAS code and loads directly to the ##
##       CAS server, bypassing the Compute server.                ##
####################################################################

##
## CONNECT TO THE DISTRIBUTED CAS SERVER  ##
##

## Add certificate location to operating system's list of trusted certs.
os.environ['CAS_CLIENT_SSL_CA_LIST']=os.environ['SSLCALISTLOC']

## Connect to the CAS server for distributed processing
conn = swat.CAS(hostname="sas-cas-server-default-client",port=5570, password=os.environ['SAS_SERVICES_TOKEN'])

## View the version of Viya and confirm the connection works
print(conn.about()['About']['Viya Version'])

##
## LOAD THE DATAFRAME TO THE CAS SERVER DIRECTLY
##

## Drop the CAS table if it already exists (required when overwriting CAS tables)
tbl = conn.CASTable('pop2021_python_editor', caslib = 'casuser')
tbl.dropTable(quiet = True)


## Load the DataFrame directly to the CAS server
conn.upload_frame(df, 
                  casout = {
						'name':'pop2021_python_editor',
						'caslib':'casuser',
						'promote':True
				  })

conn.terminate()

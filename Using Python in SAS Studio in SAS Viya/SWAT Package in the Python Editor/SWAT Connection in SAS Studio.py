#######################################################################
## CONNECT THE PYTHON EDITOR TO THE CAS SERVER WITH THE SWAT PACKAGE ##
#######################################################################
## Blog Link: https://communities.sas.com/t5/SAS-Communities-Library/Hotwire-your-SWAT-inside-SAS-Studio/ta-p/835956


##
## Import packages
##
import os
import swat
import pandas as pd
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt

## Options
pd.set_option('display.max_columns', 40)

## Check versions
print(f'Pandas version:{pd.__version__}')
print(f'Numpy version:{np.__version__}')
print(f'SWAT version:{swat.__version__}')



############################################
## CONNECT TO THE DISTRIBUTED CAS SERVER  ##
############################################

## Add certificate location to operating system's list of trusted certs.
os.environ['CAS_CLIENT_SSL_CA_LIST']=os.environ['SSLCALISTLOC']

## Connect to the CAS server for distributed processing
conn = swat.CAS(hostname="sas-cas-server-default-client",port=5570, password=os.environ['SAS_SERVICES_TOKEN'])

## View the version of Viya and confirm the connection works
print(conn.about()['About']['Viya Version'])



####################################
## EXPLORE THE AVAILABLE CAS DATA ##
####################################

## View available CAS libraries
cr = conn.caslibInfo()
print(cr)


## View available files in the Samples caslib
cr = conn.fileInfo(caslib = 'samples')
print(cr)


## Load data into memory on the distributed CAS server for MPP
loadFile = 'RAND_RETAILDEMO.sashdat'
fileLoc = 'samples'
outCasTable = {'name':'retail_sales', 'caslib':'casuser'}

conn.loadTable(path = loadFile, caslib = fileLoc, casout = outCasTable)


## View available in-memory tables
cr = conn.tableInfo(caslib = 'casuser')
print(cr)


## Reference the CAS table
tbl = conn.CASTable('retail_sales', caslib = 'casuser')
print(tbl.head())
print(tbl.shape)


##############################################
## GENERAL ANALYTICS USING THE CAS CLUSTER  ##
##############################################

## Store the results from CAS into a client side DataFrame
df = tbl.loyalty_card.value_counts()
print(df)


## CREATE AND SAVE VISUALIZATION

## Set path to the output folder
outpath = SAS.symget("_USERHOME") + '/output'

## Get today's date
todaysDate = datetime.today().strftime('%Y-%m-%d')

## Plot and save the image
df.plot(kind='bar', title=f'Loyalty Card Members as of {todaysDate}')
SAS.pyplot(plt, filename=f'loyalty_members_{todaysDate}',filepath=outpath, filetype='png')

## Simple descriptive statistics
cr = tbl.summary()
print(cr)


## Simple frequency values
col_to_freq = ['Department','brand_name', 'Storechain']
cr = tbl.freq(inputs = col_to_freq)
print(cr)


#########################
## DATA PREPARATION    ##
#########################

## Preview data
print(tbl.head())


## DROP AND RENAME COLUMNS

## Columns to drop
dropColumns = ['trx_hr_char', 'trx_dow_new', 'trx_tod', 'sss','Region_2', 'Region_2_Lat', 'Region_2_Long']


## RENAME COLUMNS BY UPPER CASING COLUMN NAMES

# Get list of columns
colNames = tbl.columns.to_list()
print(colNames)

# Create a list of dictionarires to rename columns
newColNames  = [{'name':col, 'rename':col.upper()} for col in colNames]
print(newColNames)

# Drop and rename columns
tbl.alterTable(columns = newColNames, drop = dropColumns)

## View CAS table
print(tbl.head())



## CREATE NEW COLUMNS
tbl.eval("TOTAL_PROFIT = SALES - COST ")
tbl.eval("LOYALTY_CARD_VALUE = IFC(LOYALTY_CARD = 1, 'YES', 'NO')" )

print(tbl.head())


##
## CREATE A NEW IN-MEMORY CAS TABLE
##
tbl.copyTable(casout={'name':'final_sales', 
					  'caslib':'casuser', 
                      'label':'final sales production data',
                      'replace':True})


## View in-memory tables
cr = conn.tableInfo(caslib = 'casuser')
print(cr)


## Reference new CAS Table
finalTbl = conn.CASTable('final_sales', caslib = 'casuser')


## SAVE THE CAS TABLE TO A DATA SOURCE
finalTbl.save(name=f'final_sales_{todaysDate}.parquet', caslib='casuser', replace = True)

cr = conn.fileInfo(caslib = 'casuser')
print(cr)

##
## Terminate the CAS connection
##

## Delete source file and promoted CAS table that was created (optional)
#conn.deleteSource(source=f'final_sales_{todaysDate}.parquet', caslib = 'casuser')

conn.terminate()


##
## SCHEDULE THIS PIPELINE AS A JOB
##
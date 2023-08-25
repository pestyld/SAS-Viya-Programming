##################################################################
## USING SAS CALLBACK METHODS IN THE PYTHON EDITOR/PROC PYTHON  ##
##################################################################

## SAS Callback Methods Documentation
## https://go.documentation.sas.com/doc/en/pgmsascdc/default/proc/n1x71i41z1ewqsn19j6k9jxoi5fa.htm?fromDefault=

## 
## View available packages (takes about a minute)
##
#help('modules')


##
## Import packages
##
import pandas as pd
import os
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

## Options
pd.set_option('display.max_columns', 20)

## Check versions
print(f'Pandas version:{pd.__version__}')
print(f'Numpy version:{np.__version__}')



#######################################################################
## Accessing Data on the Compute Server                              ##     
#######################################################################
## NOTE: Valid in the Python editor and PROC Python

##
## SAS data -> DataFrame (SAS.sd2df)
##

## Specify the SAS library and table name. DATA set options are available
df_raw = SAS.sd2df('sashelp.cars(drop=Weight  Wheelbase  Length)')

## You have to print results
print(type(df_raw))
print(df_raw.head())


## Simple exploration
nmiss = df_raw.isna().sum()
print(nmiss)


## Simple data prep using Pandas
df = (df_raw
      .rename(columns=lambda col: col.upper())     ## Uppercase all column names
      .assign(
			MPG_AVG = lambda _df : _df.loc[:,['MPG_CITY','MPG_HIGHWAY']].mean(axis = 'columns'),   ## Create new column with mean of MPG
            CYLINDERS = lambda _df: _df['CYLINDERS'].fillna(value = _df['CYLINDERS'].mean())       ## Replace missing values in a column
	  )
)
print(df.head())
print(df.isna().sum())


##
## DataFrame -> SAS data set - sas7bdat (SAS.df2sd)
##

## Transfer the DataFrame to a traditional SAS library on the Compute server
SAS.df2sd(df, 'work.myDataFrame')



#############################################
## Accessing Data on the CAS Server        ##     
#############################################
## Data comes from a distributed CAS table -> Compute server -> DataFrame

## Specify the libref to a caslib library
df_from_cas = SAS.sd2df('casuser.cars')

print(df_from_cas.head())


## Transfer the DataFrame to a a caslib on the CAS server 
## Data comes from a DataFrame -> Compute server -> distributed CAS table
SAS.df2sd(df_from_cas, 'casuser.myCASTableFromDataFrame')



###########################################
## Submitting SAS Code using Python      ##     
###########################################

##
## COMPUTE SERVER PROCESSING
##

## Submit simple PRINT procedure
SAS.submit('''
proc print data=sashelp.cars(obs=10) label;
run;
''')


## Storing descriptive statistics from MEANS
SAS.submit('''
proc means data=sashelp.cars;
    class Make;
	var MSRP Invoice MPG_City;
    output out=cars_summary;
run;
''')
## SAS data set as a DataFrame
cars_summary_df = SAS.sd2df('work.cars_summary')
print(cars_summary_df.head(10))


## Create SAS tables with a procedure and then create DataFrames
SAS.submit('''
proc freq data=sashelp.cars order=freq ;
	tables Make / out=freq_make;
	tables Origin / out=freq_origin;
run;
''')
## SAS data set as a DataFrame
freq_model_df = SAS.sd2df('work.freq_make')
print(freq_model_df)


##
## CAS SERVER DISTRIBUTED PROCESSING
##

## Use Python f strings
myCasTable = 'casuser.cars'

SAS.submit(f'''
proc mdsummary data={myCasTable};
	var MSRP MPG_City;
	groupby Make;
	output out=casuser.cars_cas_summary;
run;
''')
## Distributed CAS table as a DataFrame
cars_cas_df = SAS.sd2df('casuser.cars_cas_summary')
print(cars_cas_df.head())



###################################################################
## Create references to data via library reference or a caslib   ##   
###################################################################
## NOTE: Be careful with the semi-colon. If you forget the       ##
##       the semi-colon an error will occur and you might have   ##
##       to reset the SAS session.                               ##
###################################################################

##
## GET THE SERVER PATH
##

## Python lives in a container separate from SAS.
## The getcwd method shows the path to the Python container, not the server path on the left.
print(os.getcwd())


## View all stored macro variables
## The _USERHOME macro variable points to your home folder on the server
SAS.submit('%put _all_;')


## Get the path to your home folder on the server using the SAS macro variable _USERHOME
home_path = SAS.symget("_USERHOME")
print(home_path)

## Set path to the output folder
outpath = home_path + '/output'


##
## CREATE A TRADITIONAL SAS LIBRARY REFERENCE
##

## Path to the data folder as an example
path = home_path + '/data'
print(path)

## Create a libref on the Compute server
sas_statement = f"libname mydata '{path}';"
print(sas_statement)

## Submit the SAS statement
SAS.submit(sas_statement)


##
## CREATE LIBRARY REFERENCE TO A CASLIB FOR DISTRIBUTED PROCESSING (MPP)
##
SAS.submit('libname public cas caslib="public";')



###################################################
## Data Visualization with Python in SAS Studio  ##     
###################################################

## Use the DataFrame created in this demo
print(df.head())


##
## USING THE PANDAS PLOT METHOD
##

## Plot won't show by default
df.plot.scatter(x = 'TYPE', y = 'MPG_AVG', figsize = (8,6), title = 'MPG Average by Type')

## Use the SAS.pyplot method and call plt
SAS.pyplot(plt)

## Clear the current figure. 
plt.clf()                                    


##
## USING MATPLOTLIB
##

fig, ax = plt.subplots(figsize = (8,6))
ax.scatter(x = df['TYPE'], y = df['MPG_AVG'])
ax.set_title('MPG Average by Type')
SAS.pyplot(fig)                              ## Show image in results using the figure


##
## SAVE AND RENDER THE IMAGE
##

## By default image is saved as svg if not specified in method
SAS.pyplot(fig, filename='my_scatter_plot',filepath=outpath, filetype='png')


##
## RENDER AN IMAGE FILE
##
SAS.renderImage(outpath + '/my_scatter_plot.png')
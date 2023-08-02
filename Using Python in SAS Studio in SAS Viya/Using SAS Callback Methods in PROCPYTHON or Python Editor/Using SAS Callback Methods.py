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
import numpy as np
import matplotlib.pyplot as plt

## Options
pd.set_option('display.max_columns', 20)

## Check versions
print(f'Pandas version:{pd.__version__}')
print(f'Numpy version:{np.__version__}')


###############################################
## SAS Callback Methods for Data Transfer    ##     
###############################################
## NOTE: Valid in the Python editor and PROC Python


##
## SAS data -> DataFrame (SAS.sd2df)
##

## Specify the SAS library and table name. DATA set options are available
df_raw = SAS.sd2df('sashelp.cars(drop=Weight  Wheelbase  Length)')
print(type(df_raw), df_raw.head())


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
print(df.head(), df.isna().sum())


##
## DataFrame -> SAS data (SAS.df2sd)
##

## Traditional SAS library
SAS.df2sd(df, 'work.myDataFrame')



###########################################
## Submitting SAS Code using Python      ##     
###########################################

## Create traditional SAS library reference if necessary (Be careful with the semi-colon)
path = r'/greenmonthly-export/ssemonthly/homes/Peter.Styliadis@sas.com/Data'
SAS.submit(f"libname mydata '{path}';")

## Create library reference to a calsib if necessary
SAS.submit('libname casuser cas caslib="casuser";')

## Transfer the DataFrame to a traditional SAS library on the Compute server
SAS.df2sd(df, 'mydata.myDataFrameCompute')

## Transfer the DataFrame to a a caslib on the CAS server 
SAS.df2sd(df, 'casuser.myDataFrameCAS')


## Other?
## Specific PROC and bring output as a dataframe?
## etc?


###########################################
## Data Visualization with Python        ##     
###########################################

##
## Using the pandas plot method
##
df.plot.scatter(x = 'TYPE', y = 'MPG_AVG', figsize = (8,6), title = 'MPG Average by Type')

## Show image in results
SAS.pyplot(plt)

## Save and render the image file
## By default image is saved as svg if not specified in method
SAS.pyplot(plt, filename='newimage',filepath=path, filetype='png')

##
## Render an image file that is already created
##
SAS.renderImage(path + '/newimage.png')
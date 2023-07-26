## Place link..... 


##
## Import packages
##
import pandas as pd
import numpy as np

## Options
pd.set_option('display.max_columns', 25)

## Check versions
print(f'Pandas version:{pd.__version__}')
print(f'Numpy version:{np.__version__}')


###########################################
## SAS Callback Methods Data Transfer    ##     
###########################################
## NOTE: Valid in the Python editor and PROC Python

##
## SAS data -> DataFrame (SAS.sd2df)
##

df_raw = SAS.sd2df('sashelp.cars(drop=Weight  Wheelbase  Length)')
print(type(df_raw), df_raw.head())


## Simple exploration
nmiss = df_raw.isna().sum()
print(nmiss)


## Simple data prep using Pandas
df = (df_raw
      .rename(columns=lambda col: col.upper())     ## Uppercase all column names
      .assign(
			MPG_AVG = lambda _df : _df.loc[:,['MPG_CITY','MPG_HIGHWAY']].mean(axis = 'columns'),   ## Create new column
            CYLINDERS = lambda _df: _df['CYLINDERS'].fillna(value = _df['CYLINDERS'].mean())       ## Replace missing values
	  )
)

print(df.head(), df.isna().sum())


##
## DataFrame -> SAS data (SAS.df2sd)
##

## Traditional SAS library
SAS.df2sd(df, 'work.test')


###########################################
## Submitting SAS Code using Python      ##     
###########################################

## Create library references if necessary
SAS.submit('libname casuser cas caslib="casuser"')

## Caslib (must be setup prior. You can do that using the SAS.submit method (shown below))
SAS.df2sd(df, 'casuser.test')


## Other? Load to CAS? Specific PROC and bring output as a dataframe?



###########################################
## Data Visualization with Python        ##     
###########################################






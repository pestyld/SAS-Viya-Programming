/****************************************/
/* Submit Python code using PROC PYTHON */
/****************************************/

/* Perform data preprocessing in using Python */ 
proc python;
submit;

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
SAS.df2sd(df, 'work.myDataFrame_PROCPYTHON')


endsubmit;
quit;


/****************************************************/
/* Use SAS procedures on the final data from Python */
/****************************************************/
proc print data=work.myDataFrame_PROCPYTHON(obs=10);
run;

proc means data=work.myDataFrame_PROCPYTHON n mean max min;
	class Make;
	var MSRP MPG_AVG;
run;

title height=16pt justify=left color=red 'MPG Average by Type';
proc sgplot data=work.myDataFrame_PROCPYTHON;
	scatter x=Type y=MPG_Avg;
quit;
title;
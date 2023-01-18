import requests
import pandas as pd


##
## CLEAN JSON DATA FUNCTION 
##

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



##
## REQUEST TO THE CENSUS API
##

# Folder path to the API key csv file. Store the API key in the variable api_key
path = SAS.symget("editor_path")
file = 'census_api.csv'
api_key = (pd
           .read_csv(path + file, header = None)
           .loc[0,0])

# Parameters for the get request
parameters = {'get' : 'DENSITY_2021,POP_2021,NAME,NPOPCHG_2021',
              'for' : 'state',
              'key' : api_key}

# Census API URL
census_url = 'https://api.census.gov/data/2021/pep/population?'

# Send the get request
data = requests.get(census_url, params = parameters, timeout = 5)



##
## CREATE A DATAFRAME WITH THE JSON FILE USING THE USER DEFINED FUNCTION
##

df = createData(data)
print(df)


##
## SEND THE DATAFRAME TO EITHER THE SAS COMPUTE SERVER, OR THE CAS SERVER
##

# Send the data to the CAS server and promote the table to use SAS Visual Analytics
SAS.df2sd(df, 'casuser.pop2021_python_editor(PROMOTE=YES)')

# Send the data to the compute server
SAS.df2sd(df, 'work.pop2021_python_editor')
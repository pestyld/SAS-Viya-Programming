## Blog Link: https://communities.sas.com/t5/SAS-Communities-Library/Hotwire-your-SWAT-inside-SAS-Studio/ta-p/835956
import os
import swat

# Add certificate location to operating system's list of trusted certs.
os.environ['CAS_CLIENT_SSL_CA_LIST']=os.environ['SSLCALISTLOC']

conn = swat.CAS(hostname="sas-cas-server-default-client",port=5570, password=os.environ['SAS_SERVICES_TOKEN'])

print(conn.about())

## quick data prep and replace global table for other Viya app.


conn.terminate()
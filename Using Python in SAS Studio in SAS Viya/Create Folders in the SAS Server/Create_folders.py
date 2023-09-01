####################################################
## CREATE FOLDER ON THE SAS SERVER USING PYTHON   ##
####################################################

import os

## The _USERHOME macro variable holds the path information for the SAS server
## Store the path in a variable
serverPath = SAS.symget("_USERHOME")
print(serverPath)



##
## Create folder function
##

def createFolder(folderName):

	## Path of the SAS server
	serverPath = SAS.symget("_USERHOME") 

	## Make new folder on the server
	os.mkdir(serverPath + '/' + folderName)



## Create the folders. Depends on your Viya permissions
createFolder('test_folder_1')
createFolder('test_folder_2')
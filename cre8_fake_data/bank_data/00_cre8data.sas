******************************************************************************************;
* PROGRAM DESCRIPTION: Create Fake Bank Data                                             *;
* DATE: 09/28/2021                                                                       *;
******************************************************************************************;
* SUMMARY:                                                                               *;
*	- Creates fakes bank data. Creates fake loan, customer and app rating data. Also     *;
*     utilizes the heart and cars sashelp tables.                                        *;
*	- All data will be created in the casuser caslib. No data is deleted from the        *;
*	  casuser caslib in case you have files/tables you need.                             *;
*	- Program saves a variety of data source files in different formats.                 *;
*   - The fake data is created based on the number of threads on the CAS server. These   *;
*     can be adjusted in the 'Set Number of Customers' section below.                    *; 
******************************************************************************************;
* REQUIREMENTS:                                                                          *;
* 1. All execute programs reside in same folder location.                                *;
* - 01_cre8loan_raw.sas                                                                  *;
* - 02_cre8customer_raw.sas                                                              *;
* - 03_cre8appratings.sas                                                                *;
* - 04_cre8sashelp_data.sas                                                              *;
* - 05_utility.sas                                                                       *;
* 2. Folder path is set to the folder this program resides in.                           *;
* 3. You can modify the numLoanCustomers, numAdditionalCustomers ,numRatings macro       *;
*    variables below to specify the size of the tables.                                  *;
******************************************************************************************;
* FILES CREATED (by default, the CASUSER caslib is used):                                *;
* - loans_raw CAS table (deletes) -> loans_raw.sashdat(saves)                            *;
* - customers CAS table (deletes). Table is used to create customers_raw CAS table       *;
* - customers_raw CAS table (deletes) -> customers_raw.csv(saves)                        *;
* - appRatings CAS table (deletes) -> AppRatings.sashdat(saves)                          *;
* - cars CAS table (deletes), cars.txt, cars.sas7bdat(saves)                             *;
* - heart CAS table (deletes) -> heart.sashdat(saves)                                    *;
******************************************************************************************;
* FINAL OUTPUT: 1 promoted in-memory table (cars), 6 data source files                   *;
******************************************************************************************;

*******************************************;
* Set the folder path                     *;
*******************************************;
* Current folder. SAS program must be saved in the folder location for this to work *; 
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

*******************************************;
* Set output caslib                       *;
*******************************************;
%let outputCaslib = casuser;

***********************************************************************************;
* Set Number of Customers and App Ratings                                         *;
* NOTE: Total number of rows = (specified number) x (number of available threads) *;
***********************************************************************************;
* - Sets the number of customers to use in 01_cre8loan_raw.sas. Customers can have multiple accounts *;
%let numLoanCustomers = 100;
* - Sets the number of additional customers to add without loans in 02_cre8customer_raw.sas. Customers here only having savings and checking accounts *; 
%let numAdditionalCustomers = 100;
* - Sets the number of app ratings for the products in 03_cre8appratings.sas *;
%let numRatings = 200;


*****************************;
* Create Connection to CAS  *;
*****************************;
cas conn;

* Library reference to the casuser caslib *;
libname &outputCaslib cas caslib="&outputCaslib";

******************************;
* Execute cre8 Data Programs *;
******************************;
%include "&path/01_cre8loans_raw.sas";
%include "&path/02_cre8customer_raw.sas";
%include "&path/03_cre8appratings.sas";
%include "&path/04_cre8sashelp_data.sas";
%include "&path/05_utility.sas";


*************************;
* Terminate Connection  *;
*************************;
cas conn terminate;
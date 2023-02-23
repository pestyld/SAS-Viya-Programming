
* Customers Table *;
data &outputCaslib..customers_raw;
    set &outputCaslib..customers end=eof;
    length Email $3. Address $3. Country $2. accNonCC 8.;
    retain Email '***' Address '***';
    *****************************************************************;
    * 1. Create an array of column names indicating type of account *;
    *****************************************************************;
    array colNames[13] 8.   LoanCreditCard      /*1*/
                            LoanConsolidation   /*2*/
                            LoanMortgage        /*3*/
                            LoanHomeImprovement /*4*/
                            LoanCarLoan         /*5*/
                            LoanPersonal        /*6*/
                            LoanMovingExpenses  /*7*/
                            LoanSmallBusiness   /*8*/
                            LoanVacation        /*9*/
                            LoanMedical         /*10*/
                            LoanMajorPurchase   /*11*/
                            LoanWeddings        /*12*/
                            LoanEducation;      /*13*/


    *****************************************;
    * 2. Create an array of category values *;
    *****************************************;
    array category_group[13] varchar(16) _temporary_ ("Credit Card",     /*1*/
                                                      "Consolidation",   /*2*/
                                                      "Mortgage",        /*3*/
                                                      "Home Improvement",/*4*/
                                                      "Car Loan",        /*5*/
                                                      "Personal",        /*6*/
                                                      "Moving Expenses", /*7*/
                                                      "Small Business",  /*8*/
                                                      "Vacation",        /*9*/
                                                      "Medical",         /*10*/
                                                      "Major Purchase",  /*11*/
                                                      "Weddings",        /*12*/
                                                      "Education");      /*13*/


    ***********************************************************;
    * 3. Loop over each list of accounts and create indicator *;
    ***********************************************************;
    do i=1 to dim(category_group);
        colNames[i] = count(CurrentCategories,category_group[i]);  
    end;

    *****************************************************************;
    * 4. Determine if customer only has CC account to create coutry *;
    *****************************************************************;
    * Check to see if any category has a loan since only US serves other loans. *;
    accNonCC=sum(LoanConsolidation,LoanMortgage,LoanHomeImprovement,LoanCarLoan,LoanPersonal,LoanMovingExpenses,LoanSmallBusiness,LoanVacation,LoanMedical,LoanMajorPurchase,LoanWeddings,LoanEducation);

    * If it contains loans other than credit cards set to US only*;
    if AccNonCC > 0 then do;
        Country='US';
    end;
    * If just credit cards, can be other countries *;
    else do;
        array country_group[5] varchar(16) _temporary_ ("GR","DE","GBR","CA","US");
        randCountry=rand('table',.05,.27,.18,.30,.20);
        Country=country_group[randCountry];
    end;

    ******************************************;
    * 5. Create Saving and Checking Accounts *;
    ******************************************;
    * Create a savings/checking account randomly *;    
    randSavings=rand('table',.70, .30);

    * With savings account *;
    if randSavings=1 then do;
        SavingsAcct=1;
        * Most people with a savings account having a checking *;
        randChecking=rand('table',.90, .10);
        if RandChecking=1 then CheckingAcct=1;
            else CheckingAcct=0;
    end;
    * Without savings account *;
    else do;
        SavingsAcct=0;
        * Without a savings account it's 50/50 checking *;
        randChecking=rand('table',.50, .50);
        if RandChecking=1 then CheckingAcct=1;
            else CheckingAcct=0;
    end;

    output;

    * Customers with just savings/checking accounts *;
    if eof=1 then do;
        do numExtra=1 to &numAdditionalCustomers;  /*Modify the value to create n number of customers per thread */

		   * Set all other columns to 0 *;
           do i=1 to dim(category_group);
              colNames[i] = 0;
           end;

           * Set random country using array from above *;
           randCountry=rand('table',.07,.27,.18,.25,.23);
           Country=country_group[randCountry];

		   * Set random country using array from above *;
		   Date = round(rand('uniform', mdy(1,1,2013),mdy(12,31,2022)));


           * Random uniform age *;
           Age=round(rand('uniform',18,65));

           * Set salary based on age *;
           if Age < 19 then Salary=round(rand('normal',15000,3500));
              else if Age < 24 then Salary=round(rand('normal',35000,7000));
              else if Age < 34 then Salary=round(rand('normal',50000,7000));
              else if Age < 44 then Salary=round(rand('normal',60000,7000));
              else if Age < 54 then Salary=round(rand('normal',65000,7000));
              else Salary=round(rand('normal',70000,7500));

           * Random salary outliers *;
           randSalOutlier=rand('uniform',0,1);
           if randSalOutlier < .05 then do;
                if Age > 24 then Salary=round(Salary * 1.5);
           end;
           else if randSalOutlier > .5 and randSalOutlier < .6 then do;
                Salary=.;
           end;
           else if randSalOutlier > .75 then do;
                Salary=round(Salary * .6);
           end; 

           * No emp length since these are not loans *;
           EmpLength=.;

           * Create customer ID *;
           array rand_letter[10] varchar(1) _temporary_ ('K','L','M','N','O','P','Q','R','S','T');
           randLetter=rand('table',.1,.1,.1,.1,.1,.1,.1,.1,.1,.1);
           ID=catx('-',rand_letter[randLetter],put(rand('uniform',0,9999999999999999),z20.));
           output;

        end;

    end;

    drop i rand: CurrentCategories numExtra accNonCC;
run;


* Save the customers_raw CAS table as a csv file and drop the customers/customers_raw CAS tables *;
proc cas;
    table.save / 
        table={name='customers_raw', caslib="&outputCaslib"},
        name='customers_raw.csv', caslib="&outputCaslib",
        replace=TRUE;

* Check the new customers CAS table size *;
	table.tableInfo / caslib="&outputCaslib";

* Drop the customers and customers_raw tables *;
    droptbls={'customers', 'customers_raw'};
    do i over droptbls;
        table.dropTable / name=i, caslib="&outputCaslib", quiet=TRUE;
    end;
quit;
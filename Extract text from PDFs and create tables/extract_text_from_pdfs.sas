/*****************************/
/* READ PDF FILES INTO CAS   */
/*****************************/


/******************************************************/
/* Folder structure of files                          */
/******************************************************/
/* > Extract text from PDFs and create tables (folder)*/
/*   > PDF_files (3 sample PDF files)                 */
/*    -- PDF_Form_1.pdf                               */
/*    -- PDF_Form_2.pdf                               */
/*    -- PDF_Form_3.pdf                               */
/*   extract_text_from_pdfs.sas (solution program)    */
/******************************************************/

/******************************************/
/* FIND PATH FOR THE PROJECT FOLDER       */
/******************************************/
/* Dynamically finds the current directory path based on where the program is saved and stores it in the path macro variable */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

/* Confirm the path is as expected */
%put &=path;



/***********************************************************/
/* CONNECT TO CAS AND LOAD PDF FILES INTO A CAS TABLE      */
/***********************************************************/
/* loadTable action (has the import option info - https://go.documentation.sas.com/doc/en/pgmsascdc/default/caspg/cas-table-loadtable.htm */
/* PROC CASUTIL - https://go.documentation.sas.com/doc/en/pgmsascdc/default/casref/n03spmi9ixzq5pn11lneipfwyu8b.htm#n1nj5zckmttquen1siwyi8gfsf0q */
/* Create a caslib to the folder with the PDFs in the PDF_files folder */
caslib my_pdfs path="&path./PDF_files" subdirs;


/* View all files in the my_pdfs caslib. 3 PDF files should exist. */
proc casutil;
	list files incaslib='my_pdfs'; 
quit;


/* Read in all of the PDF files in the caslib as a single CAS table */
/* Each PDF will be one row of data in the CAS table                */
proc casutil;
    load casdata=''                        /* To read in all files use an empty string. For a single PDF file specify the name and extension */
         incaslib='my_pdfs'                /* The location of the PDF files to load */
         importoptions=(fileType="document" fileExtList = 'PDF' tikaConv=True)   /* Specify document import options   */
		 casout='pdf_data' outcaslib='casuser' replace;                          /* Specify the output cas table info */
quit;

/* Preview the new CAS table */
proc print data=casuser.pdf_data(obs=10);
run;

/****************************************************/
/* Using native CAS Language (CASL) - OPTIONAL      */
/****************************************************/
/* The CASUTIL procedure uses the loadTable         */
/* action through the CAS engine behind the scenes. */
/* Instead of using CASUTIL you can call the action */
/* directly.                                        */
/****************************************************/

/* proc cas; */
/* 	table.loadTable / */
/* 		path = "",                                */
/*         caslib = 'my_pdfs',            */
/*         importOptions = {               */
/*               fileType = 'DOCUMENT', */
/*               fileExtList = 'PDF', */
/*               tikaConv = TRUE */
/*         }, */
/*         casOut = {                      */
/* 				  name = 'pdf_data',  */
/* 				  caslib = 'casuser',  */
/* 				  replace = True */
/* 		}; */
/*  */
/* 	table.fetch / table={name = 'pdf_data', caslib = 'casuser'}; */
/* quit; */



/******************************************************************************/
/* CLEAN THE UNSTRUCTURED DATA                                                */
/******************************************************************************/
/* Step 1 - Build some logic to figure out how to clean the unstructured data */
/* Step 2 - Finalize the ETL pipeline                                         */
/******************************************************************************/

/* Step 1 - DEVELOPMENT - figure out the general programming logic to clean the unstructured text */
data work.final_pdf_data;
	set casuser.pdf_data;
	length FormFieldsData $10000;
	drop path fileType fileDate;

	/* Create a column with just the form entries */
	firstFormField = 'Company Name:';
	formStartPosition = find(content, firstFormField);

	/* Get form field input only */
	FormFieldsData = strip(substr(content,formStartPosition));

	/* Remove random special characters and whitespace from form entries*/
	FormFieldsData = strip(FormFieldsData);
	FormFieldsData = tranwrd(FormFieldsData,'09'x,''); /* Remove tabs */
	FormFieldsData = tranwrd(FormFieldsData,'0A'x,''); /* Remove carriage return line feed */

	/* Find the first input field: Company */
	find_first_form_position = find(FormFieldsData,'Company Name:') + length('Company Name:');
	find_second_form_position = find(FormFieldsData, 'First Name:');
	find_length_of_value = find_second_form_position - find_first_form_position;
	Company = substr(FormFieldsData,find_first_form_position, find_length_of_value);

	/* Find the first input field: Company */
	find_first_form_position = find(FormFieldsData, 'First Name:') + length('First Name:');
	find_second_form_position = find(FormFieldsData, 'Last Name:');
	find_length_of_value = find_second_form_position - find_first_form_position;
	FirstName = substr(FormFieldsData, find_first_form_position, find_length_of_value);
run;

/* Preview the clean data */
proc print data=work.final_pdf_data;
run;



/**************************************************************************************/
/* Step 2 - Finalize ETL pipeline (production)                                        */
/* 	 1. Create user defined function (UDF) to parse each input field to clean up code */
/*   2. Apply UDF to clean up the unstructure data                                    */
/**************************************************************************************/

/***********************/
/* STEP 1 - CREATE UDF */
/***********************/
proc fcmp outlib=work.funcs.trial;
	function find_pdf_value(formFieldsData $, field_to_find $, next_field $) $;
/*
This function will obtain the text input field between two input objects and return the value as a character

- formFieldsData - The string that contains the text from the PDF
- field_to_find - The name of the first input field object (includes the :)
- next_field - The field to parse the input field to (includes the :)
*/

		/* Find position of the text to obtain */
		find_first_form_position = find(FormFieldsData, field_to_find) + length(field_to_find);
		find_second_form_position = find(FormFieldsData, next_field);
		find_length_of_value = find_second_form_position - find_first_form_position;

		/* Get the PDF input field value */
		length pdf_values $1000;
		pdf_values = substr(FormFieldsData, find_first_form_position, find_length_of_value);
		return(pdf_values);

    endsub;
run;


/***********************/
/* STEP 2 - CLEAN DATA */
/***********************/

/* Point to the FCMP function */
options cmplib=work.funcs;

/* Clean the data */
data final_pdf_data;
	set casuser.pdf_data;

	/* Sent length of extract text column */
	length FormFieldsData $10000;

	/* Drop unncessary columns */
	drop path fileType fileSize firstFormField formStartPosition;

	/* Create a column with just the form entries */
	firstFormField = 'Company Name:';
	formStartPosition = find(content, firstFormField);

	/* Get form field input only */
	FormFieldsData = strip(substr(content,formStartPosition));

	/* Remove random special characters and whitespace from form entries*/
	FormFieldsData = strip(FormFieldsData);
	FormFieldsData = tranwrd(FormFieldsData,'09'x,''); /* Remove tabs */
	FormFieldsData = tranwrd(FormFieldsData,'0A'x,''); /* Remove carriage return line feed */

	/* Extract values */
	Date = find_pdf_value(FormFieldsData, 'Date:','Group2:'); 
	Company_Name = find_pdf_value(FormFieldsData, 'Company Name:', 'First Name:');
	/* Group2: */
	Membership = find_pdf_value(FormFieldsData,'Group2:','Member ID:');
	Member_ID = find_pdf_value(FormFieldsData, 'Member ID:','Group3:');
	First_Name = find_pdf_value(FormFieldsData, 'First Name:', 'Last Name:');
	Last_Name = find_pdf_value(FormFieldsData, 'Last Name:', 'Address:');
	Address = find_pdf_value(FormFieldsData, 'Address:', 'City:');
	City = find_pdf_value(FormFieldsData, 'City:','State:');
	State = find_pdf_value(FormFieldsData, 'State:', 'Zip:');
	Zip = find_pdf_value(FormFieldsData, 'Zip:', 'Phone:');
	Phone = find_pdf_value(FormFieldsData, 'Phone:', 'Email:');
	Email = find_pdf_value(FormFieldsData, ' Email:', 'undefined_2:');
	/* Group3: */
	Membership_Status = find_pdf_value(FormFieldsData, 'Group3:','undefined:');
	/* undefined: */
	Service_Consulting = find_pdf_value(FormFieldsData, 'undefined:', 'Comments:');
	/* undefined_2: */
	Service_Mentoring = find_pdf_value(FormFieldsData, 'undefined_2:', 'undefined_3:');
	/* undefined_3: */
	Service_Live_Training = find_pdf_value(FormFieldsData, 'undefined_3:', 'Date:');
	
	/* Comments is the last value. Find Comments: then read the rest of the text */
	Comments = substr(FormFieldsData,find(FormFieldsData,'Comments:')+length('Comments:'));
run;

/* Preview the final data */
proc print data=work.final_pdf_data;
run;
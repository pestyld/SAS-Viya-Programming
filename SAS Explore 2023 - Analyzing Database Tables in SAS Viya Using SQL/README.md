# SAS Explore 2023 - Analyzing Database Tables in SAS Viya Using SQL

## Description
This Hands On Workshop (HOW) was presented at SAS Explore 2023 using an Oracle database. The techniques are similar when using other databases.

The data is too large and not provided. You can create the fake data for this workshop by modifying the **00 - cre8data.sas program**. Modify lines 27-31 to create the fake data in your database. Write access is required.

### Modify the following statement:
*caslib &outputCaslib datasource=(srctype="oracle",
                                 user="STUDENT",
                                 password="Metadata0",
                                 path="//server.demo.sas.com:1521/ORCL",
                                 schema="STUDENT");*

You can also use similar techniques with your data.

## Requirements
- You will need access to SAS Viya.
- You will need access to a database. The HOW uses Oracle
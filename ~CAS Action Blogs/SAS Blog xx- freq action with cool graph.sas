*************************************************;
* CAS-Action! Simple Frequency Tables - Part 1  *;
*************************************************;



****************************************;
* Load the sashelp.cars table into CAS *;
****************************************;
cas conn;

libname casuser cas caslib="casuser";

data casuser.cars;
    set sashelp.cars;
run;


*****;
* 1 *;
*****;
* Created a calculated column to analyze *;
proc cas;
* Create PriceTier column *;
    source priceTier;
        if MSRP < 20000 then PriceTier="Low";
            else if MSRP < 40000 then PriceTier = "Middle";
            else PriceTier="High";
    endsource;

* Analyze PriceTier *;
    simple.freq / 
        table={name="cars", caslib="casuser",
               computedVarsProgram=priceTier},
        inputs={"PriceTier"};
quit;


* Alternate solution using a text string *;
/*
proc cas;
* Create PriceTier column *;
    source priceTier;

    endsource;

* Analyze PriceTier *;
    simple.freq / 
        table={name="cars", caslib="casuser",
               computedVarsProgram='if MSRP < 20000 then PriceTier="Low";
                                      else if MSRP < 40000 then PriceTier = "Middle";
                                      else PriceTier="High";'},
        inputs={"PriceTier"};
quit;
*/


*****;
* 2 *;
*****;
* Modify the length of a calculated column *;
proc cas;
* Create PriceTier column *;
    source priceTier;
        length PriceTier varchar(6);
        if MSRP < 20000 then PriceTier="Low";
            else if MSRP < 40000 then PriceTier = "Middle";
            else PriceTier="High";
    endsource;

* Analyze PriceTier *;
    simple.freq / 
        table={name="cars", caslib="casuser",
               computedVarsProgram=priceTier},
        inputs={"PriceTier"};
quit;



*****;
* 3 *;
*****;
* Save the results of the action as a SAS data set *;
proc cas;
* Create PriceTier column *;
    source priceTier;
        length PriceTier varchar(6);
        if MSRP < 20000 then PriceTier="Low";
            else if MSRP < 40000 then PriceTier = "Middle";
            else PriceTier="High";
    endsource;

* Analyze PriceTier *;
    simple.freq result=f / 
        table={name="cars", caslib="casuser",
               computedVarsProgram=priceTier},
        inputs={"PriceTier"};
    describe f;
    print f.Frequency;

* Save the result table as a SAS data set *;
    tbl = f.Frequency[,{"Column", "CharVar", "Frequency"}];
    saveresult tbl dataout=work.TierFreq;
quit;


*****;
* 4 *;
*****;
%let txtColor=gray;
%let fmtTitle=justify=left color=&txtColor height=15pt;
%let fmtBlue=cx33A3FF;

ods graphics / height=6in;

title &fmtTitle "The Majority of Car Prices are in the " color=&fmtBlue "Middle Price Tier";
title2 &fmtTitle height=12pt "By Manufacturer's Suggested Retail Price (MSRP) in Dollars($)";
footnote &fmtTitle height=11pt "Tier Definitions: Low < $20,000, Middle < $40,000, High >= $40,000";
footnote2 &fmtTitle height=11pt "Data: SASHELP.CARS";


proc sgplot data=TierFreq
            noborder
            noautolegend;
    hbar CharVar / response=Frequency
                   categoryorder=respdesc
                   datalabel datalabelattrs=(color=&txtColor size=10pt)
                   nooutline
                   group=CharVar;
    xaxis display=none;
    yaxis labelattrs=(size=14pt color=&txtColor)
          valueattrs=(size=11pt color=&txtColor)
          label="MSRP Tiers";
    styleattrs datacolors=(&fmtBlue lightgray lightgray);

quit;
title;
footnote;








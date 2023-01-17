* Current folder. SAS program must be saved to the location *; 
%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

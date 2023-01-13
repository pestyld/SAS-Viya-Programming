%let fileName =  %scan(&_sasprogramfile,-1,'/');
%let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));
%put &=path;
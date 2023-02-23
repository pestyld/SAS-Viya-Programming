
%let a = .35;    /* Apple users (rest are Android users) */
%let mean = 4.5; /* Mean rating (unadjusted) */  
%let sd = 1.75;  /* Standard deviation of rating (unadjusted)*/

data &outputCaslib..AppRatings / sessref=conn;
  call streaminit(100);
  length RatingID varchar(30) 
		 Product $8. 
		 os $7. 
		 Version $10. 
		 Server $4.;

  * Each iteration creates one row ;
	do i = 1 to &numRatings;

		********************;
		* 1. Create Date   *;
		********************;
		* Specify the 10 years in an array. Use rand function to populate dates *;
		array year_groups[10] _temporary_ (2013,2014,2015,2016,2017,2018,2019,2020,2021,2022);

    	* Choose year;
		randSelectYear=year_groups[rand('table',.002,.014,.022,.039,.053,.103,.11,.175,.249,.233)];

    	* Choose day in year, all days equally likely;
		Date=round(rand('uniform', mdy(1,1,randSelectYear),mdy(12,31,randSelectYear)));


		********************;
		* 2. Create OS     *;
		********************;
		* Assume more droid users than IOS. Keep it simple here *;
		array app_groups[2] varchar(7) _temporary_ ('IOS','Android');	
		OS = app_groups[rand('table', &a, 1 - &a)];


		********************;
		* 3. App Version   *;
		********************;
		* Version is the letter V, first letter of the OS, the year and quarter *;
		Version=cats('V.', substr(OS,1,1), put(year(Date),4.), '.', put(qtr(Date),1.));

		***********************************;
		* 4. Feedback + Rating Categories *;
		***********************************;

    * Stories
      - Features introduced years 1, 2, 3, 4
      - Payment feature disappoints in years 3 and 4 
      - Mean rating improves over time
      - Consistency improves over time 
      - Deposit feature disappoints in years 7, 8, 9
      - Transfer feature shines in 7, 8, 9
      - IOS performs worse than Android

      - We have the ability to make a product always perform better/worse than usual
      - We have the ability to make a server always perform better/worse than usual
    ;

		array rating_groups[5] _temporary_ (1,2,3,4,5);
		array product_groups[5] varchar(8) _temporary_ ('Deposit', 'Transfer', 'Payment', 'Claims', 'Other');	

    	* Adjust mean and standard deviation for each year;
    	* Macro variables at top of program set the default mean and sd;
	  	array mean_adjustment[10] _temporary_ (0, -.2, -.3, 0, .2, .3,  .4,  .5,  .4,  .5); /* Mean improves over time */
    	array sd_adjustment[10] _temporary_ (0,  .1,   0, 0, .2, .1, -.1, -.3, -.4, -.5); /* Consistency improves over time */

		* In first year only deposits existed *;
		if Year(Date) = year_groups[1] then do;
			Product = 'Deposit';
			Rating = rand('normal', &mean + mean_adjustment[1], &sd + sd_adjustment[1]); 
		end;	

		* In beginning of Year 2 you could pay bills with account. In quarter 3 you could report claims *;
		else if Year(Date) = year_groups[2] then do;
			if Qtr(Date) <= 2 then Product = product_groups[rand('table', .65, 0, .35, 0, 0)];
			else Product = Product_groups[rand('table', .6, 0, .30, .10, 0)];

			* If the product is Payment, decrease rating by 20% *;
      		rating = rand('normal', &mean + mean_adjustment[2], &sd + sd_adjustment[2]);	
      		if Product = 'Payment' then Rating = .8 * rating;
		end;

		* 'Other' Functionality added in year 3 *;
		else if Year(Date) = year_groups[3] then do;

			Product = Product_groups[rand('table', .45, 0, .30, .10, .15)];

			* If the product is Payment, decrease rating by 40% *;	
      		rating = rand('normal', &mean + mean_adjustment[3], &sd + sd_adjustment[3]);	
      		if Product = 'Payment' then Rating = .6 * rating;
		end;

		* Money transfers added in Year 4 *;
		else if Year(Date) = year_groups[4] then do;

		  Product = Product_groups[rand('table', .35, .10, .27, .10, .18)];
	
      		* If the product is Payment, increase rating by 20% *;	
      		Rating = rand('normal', &mean + mean_adjustment[4], &sd + sd_adjustment[4]);
			if Product = 'Payment' then Rating = 1.2 * Rating;
		end;

		else if Year(Date) = year_groups[5] then do;
		    Product = Product_groups[rand('table', .25, .20, .27, .10, .18)];	
			  Rating = rand('normal', &mean + mean_adjustment[5], &sd + sd_adjustment[5]);
		end;

		else if Year(Date) = year_groups[6] then do;
		    Product = Product_groups[rand('table', .17, .28, .22, .10, .23)];	
			  Rating = rand('normal', &mean + mean_adjustment[6], &sd + sd_adjustment[6]);
		end;

    	* Deposit disappoints and transfer shines in years 7, 8, 9;
		else if Year(Date) = year_groups[7] then do;
			Product = Product_groups[rand('table', .13, .32, .20, .12, .23)];	

     		 * Deposits were worse rated, and Transfers were better rated ;
      		rating = rand('normal', &mean + mean_adjustment[7], &sd + sd_adjustment[7]);
      		if Product = 'Deposit' then Rating = .8 * rating;
      		else if Product = 'Transfer' then Rating = 1.2 * rating;
		end;

		else if Year(Date) = year_groups[8] then do;
			Product = Product_groups[rand('table', .11, .39, .14, .13, .23)];	

      		* Deposits were worse rated, and Transfers were better rated ;
			rating = rand('normal', &mean + mean_adjustment[8], &sd + sd_adjustment[8]);
      		if Product = 'Deposit' then Rating = .8 * rating;
      		else if Product = 'Transfer' then Rating = 1.2 * rating;
		end;

		else if Year(Date) = year_groups[9] then do;
			Product = Product_groups[rand('table', .08, .44, .12, .11, .25)];	
			
      		* Deposits were worse rated, and Transfers were better rated ;
     		Rating = rand('normal', &mean + mean_adjustment[9], &sd + sd_adjustment[9]);
      		if Product = 'Deposit' then Rating = .8 * rating;
      		else if Product = 'Transfer' then Rating = 1.2 * rating;
		end;

		else do;
			Product = Product_groups[rand('table', .06, .46, .1, .09, .29)];
			Rating = rand('normal', &mean + mean_adjustment[10], &sd + sd_adjustment[10]);	
		end;

		* IOS performs worse than Android *;
		if OS = 'IOS' then rating = rating * .85;

	    * Adjust for product trends;
	    * Values in product_groups are used to mulitply the existing rating;
	    * when the value = 1, the rating is unchanged;
	    array product_adjustment[5] _temporary_ (1, 1, 1, 1, 1);
	    if product = product_groups[1] then rating = rating * product_adjustment[1];
	    else if product = product_groups[2] then rating = rating * product_adjustment[2];
	    else if product = product_groups[3] then rating = rating * product_adjustment[3];
	    else if product = product_groups[4] then rating = rating * product_adjustment[4];
	    else if product = product_groups[5] then rating = rating * product_adjustment[5];


		************************;
		* 5. Server Region     *;
		************************;
	    array server_regions[4] varchar(4) _temporary_ ("APAC", "EMEA", "NAW", "NAE");
	    * didn't launch all servers at once;
	    if year(Date) <= year_groups[2] then Server = server_regions[rand('table', 0, 0, 1, 0)];
	    else if year(Date) <= year_groups[6] then Server = server_regions[rand('table', 0, 0, .4, .6)];
	    else Server = server_regions[rand('table', .15, .25, .22, .38)];
	
	    * Adjust ratings by server;
	    array server_adjustment[4] _temporary_ (1, 1, 1, 1);
	    if server = server_regions[1] then rating = rating * server_adjustment[1];
	    else if server = server_regions[2] then rating = rating * server_adjustment[2];
	    else if server = server_regions[3] then rating = rating * server_adjustment[3];
	    else if server = server_regions[4] then rating = rating * server_adjustment[4];


	    ********************;
		* 5. Set Rating ID *;
		********************;
		RatingID=catx('-',put(rand('uniform',1,999999999999),z12.),substr(Product,1,1),substr(os,1,1),Version, Server);

	    ************************;
	    * 6. Finalize Rating   *;
		************************;

	    * Round to whole number
	    * Clean up ratings < 1 or > 5;
	    Rating = round(Rating);
	    if Rating < 1 then Rating = 1;
			else if Rating > 5 then Rating = 5;


		output;
	end; * End loop *;

	drop i rand: ;
	format Date date9.;
run;


proc cas;
	table.save / 
		table={name='AppRatings', caslib="&outputCaslib"},
		caslib="&outputCaslib", name='appRatings.sashdat', replace=TRUE;

	table.tableInfo / caslib="&outputCaslib";

	table.dropTable / name='AppRatings', caslib="&outputCaslib", quiet=TRUE;
quit;
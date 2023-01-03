* PROGRAM: Replace a variable in the SOURCE block of CASL during a loop *;



* Notice that the source block simply stores a string in a variable *;
proc cas;
    source ds_code_execute;
        data casuser.test;
            x=:value:;
            output;
        run;
    endsource;

    print "-----ds_code_execute value------";
    print ds_code_execute;
    describe ds_code_execute;
quit;


* Since it stores a string, use the tranwrd function to replace the string. The key is to making the string you want to replace unique. *;
* Here I used colons around the variable(string) to replace *;
proc cas;
    source ds_code_execute;
        data casuser.test;
            x=:value:;
            output;
        run;
    endsource;

* Use a CASL has a looping feature. You can loop over the DATA step code and replace the variable for each iteration *;
    do i=1 to 5;

        * make the i variable a string *;
        make_i_a_string = putn(i,'1.');
        print make_i_a_string;

        * create a new variable with the data step code and replace whatever you want based on the unique string you used in the data step code *;
        new_ds_code=tranwrd(ds_code_execute,':value:',make_i_a_string);
        print '------------------------';
        print new_ds_code;

    end;
run;
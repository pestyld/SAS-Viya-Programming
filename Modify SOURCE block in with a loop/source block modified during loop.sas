proc cas;
    sessions={};
    source casl_code;
    %do i=1 %to 5;
        sessions[&i.]=create_parallel_session();
        sessionProp.setSessOpt session=sessions[&i.] / caslib="&caslib";
        datastep.runcode session=sessions[&i.] async="&file."
            /code=long_program /*<-- Here I prefer to use a source block to define this long_program inside of the same %do loop since it is contingent on each &i.*/
    %end;
    endsource;
    sccasl.runCasl / code=casl_code;
quit;

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


* Since it stores a string, use the tranwrd function to replace the string. The key is to making the string you want to replace unique *;
proc cas;
    source ds_code_execute;
        data casuser.test;
            x=:value:;
            output;
        run;
    endsource;

* No need for a macro loop. CASL has a looping feature *;
    do i=1 to 5;

        * make the i variable a string *;
        make_i_a_string = putn(i,'1.');
        print char_var;

        * create a new variable with the data step code and replace whatever you want based on the unique string you used in the data step code *;
        new_ds_code=tranwrd(ds_code_execute,':value:',char_var);
        print '------------------------';
        print new_ds_code;

    end;
run;


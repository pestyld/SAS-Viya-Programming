cas conn;

proc cas;

********************************;
* CREATE FUNCTION f(my_string) *;
********************************;
    function f(my_string);
        count_num_words_in_string = countw(my_string);
        new_string_to_output = "";

* Loop over each word in the string *;
        do i=1 to count_num_words_in_string;
            word = scan(my_string,i);
        * search for the brackets that contain the variable *;
            if find(word, '{') > 0 and find(word,'}') > 0 then do;
                var_name = compress(word,'{}');
                if exists(var_name)=0 then do;
                    put 'ERROR: Variable ' || var_name || ' does not exist.';
                    exit;
                end;
                else execute("myValue =" || var_name || ";" || "new_string_to_output = catx(' ',new_string_to_output, myValue);");
            end;    
            else do;
                new_string_to_output = catx(' ',new_string_to_output, word);
            end;
        end;
        return new_string_to_output;
    end;

********************************;
* Test Function                *;
********************************;

* test 1 *;
    f_name='Peter';
    l_name='Styliadis';
    my_string = "My name first name is {f_name} and last name is {l_name}";
    print "------ f function test 1---------";
    print f(my_string);


* test 2 *;
    function_name = 'string function f';
    status = 'successful';
    time_hours=3;
    my_string = 'I am testing the {function_name} to see if it is {status}. I"ve been trying for {time_hours} hours';
    print "------ f function test 2---------";
    print f(my_string);


* test 3 (error) *;
    function_name = 'f function';
    status = 'successful';
    time_hours=3;
    my_string = 'I am testing the {xffunction_name} to see if it is {status}. I"ve been trying for {time_hours} hours';
    print "------ f function test 3 (error, no variable with that name)---------";
    print f(my_string);
quit;
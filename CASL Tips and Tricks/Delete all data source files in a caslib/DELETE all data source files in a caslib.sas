proc cas;
    delete_ds_files_in_caslib = 'casuser';
    table.fileInfo result=fi / caslib=delete_ds_files_in_caslib;

    * View available files *;
    print fi;
    
    * Get a list of data source files in the caslib *;
    files_to_delete = fi.fileinfo[,'Name'];
 
    * delete data source files in a caslib *;
    do file over files_to_delete;
        table.deleteSource / 
            caslib=delete_ds_files_in_caslib, 
            source=file,
            quiet=True;
        print catx(' ', 'Deleted file:',upcase(file), 'in the:',upcase(delete_ds_files_in_caslib),'caslib');
    end;

    * Now view all files in the casuser caslib *;
    table.fileInfo / caslib = delete_ds_files_in_caslib;
quit;
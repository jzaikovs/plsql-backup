CREATE OR REPLACE TRIGGER t_plsql_backup
    BEFORE CREATE OR ALTER OR DROP
    ON SCHEMA
DECLARE
/*
The MIT License (MIT)

Copyright (c) 2013 Jānis Zaikovs

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
 */
    oper       VARCHAR2 (32000);
    sql_text   ora_name_list_t;
    n          NUMBER;
    v_stmt     VARCHAR2 (2000);
BEGIN
    oper := ora_sysevent;
    n := ora_sql_txt (sql_text);

    FOR i IN 1 .. n LOOP
        v_stmt := v_stmt || sql_text (i);
    END LOOP;

    IF oper IN ('CREATE') THEN
        IF ora_dict_obj_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'FUNCTION', 'PROCEDURE', 'TABLE') THEN
            plsql_backup.backup (ora_dict_obj_name, ora_dict_obj_type, ora_dict_obj_owner, v_stmt);
        END IF;
    ELSIF oper IN ('ALTER', 'DROP') THEN
        plsql_backup.log (sql_text (1), oper);
        plsql_backup.backup (ora_dict_obj_name, ora_dict_obj_type, ora_dict_obj_owner, v_stmt);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END t_plsql_backup;
/
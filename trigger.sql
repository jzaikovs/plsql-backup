CREATE OR REPLACE TRIGGER t_plsql_backup
    BEFORE CREATE OR ALTER OR DROP
    ON SCHEMA
DECLARE
    /*
        The MIT License (MIT)
        Copyright (c) 2016 Jānis Zaikovs
    */
    oper       VARCHAR2 (32000);
    sql_text   ora_name_list_t;
    n          NUMBER;
    v_stmt     CLOB;
BEGIN
    DBMS_LOB.createtemporary (v_stmt, TRUE, DBMS_LOB.call);
    oper := ora_sysevent;
    n := ora_sql_txt (sql_text);

    FOR i IN 1 .. n LOOP
        DBMS_LOB.writeappend (v_stmt, LENGTH (sql_text (i)), sql_text (i));
    END LOOP;

    IF ora_dict_obj_name IS NOT NULL THEN
        plsql_backup.backup (ora_dict_obj_name, ora_dict_obj_type, ora_dict_obj_owner, v_stmt, oper);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END t_plsql_backup;
/
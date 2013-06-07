CREATE OR REPLACE TRIGGER t_plsql_backup
    BEFORE CREATE OR ALTER
    ON SCHEMA
DECLARE
    oper       ddl_log.operation%TYPE;
    sql_text   ora_name_list_t;
    i          PLS_INTEGER;
BEGIN

    SELECT ora_sysevent INTO oper FROM DUAL;

    i := sql_txt(sql_text);

    -- on create
    IF oper IN ('CREATE') THEN    
        IF ora_dict_obj_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'FUNCTION', 'PROCEDURE', 'TABLE') THEN
            plsql_backup.backup (ora_dict_obj_name, ora_dict_obj_type);
        END IF;
    ELSIF oper = ('ALTER') THEN
        -- on alter
        plsql_backup.log(sql_text(1))
    END IF;    

EXCEPTION
    WHEN OTHERS THEN
        NULL;    
END t_plsql_backup;
/
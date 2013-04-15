CREATE OR REPLACE TRIGGER t_plsql_backup
    BEFORE CREATE
    ON PUNS2.SCHEMA
BEGIN
    BEGIN
        IF ora_dict_obj_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'FUNCTION', 'PROCEDURE', 'TABLE') THEN
            plsql_backup.backup (ora_dict_obj_name, ora_dict_obj_type, ora_dict_obj_owner);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
END t_plsql_backup;
/
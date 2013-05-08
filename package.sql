CREATE OR REPLACE PACKAGE plsql_backup
AS
    /*
    Procedūra kas tiek izsaukta pie objektu pārkompilācijas pateicoties shēmas trigerim
    */
    PROCEDURE backup (p_name IN VARCHAR2, p_type IN VARCHAR2);
END plsql_backup;
/

CREATE OR REPLACE PACKAGE BODY plsql_backup
AS
    /*
    Funkcija objekta koda iegūšanai
    */
    FUNCTION get_code (p_name IN VARCHAR2, p_type IN VARCHAR2)
        RETURN CLOB
    IS
        v_code   CLOB := '';
    BEGIN
        FOR src IN (  SELECT text
                        FROM user_source
                       WHERE NAME = p_name AND TYPE = p_type
                    ORDER BY line ASC)
        LOOP
            v_code := v_code || src.text;
        END LOOP;

        RETURN v_code;
    END get_code;

    /*
    Funkcija versijas arhivēšanai
    */
    PROCEDURE backup (p_name IN VARCHAR2, p_type IN VARCHAR2)
    IS
        v_revision   plsql_archive%ROWTYPE;
    BEGIN
        v_revision.name := p_name;
        v_revision.type := p_type;        
        v_revision.created := SYSDATE;
        v_revision.err := '';

        SELECT SYS_CONTEXT ('USERENV', 'OS_USER') INTO v_revision.osuser FROM DUAL;

        SELECT SYS_CONTEXT ('USERENV', 'IP_ADDRESS') INTO v_revision.ip FROM DUAL;

        BEGIN
            v_revision.src := get_code (p_name, p_type);
        EXCEPTION
            WHEN OTHERS THEN
                v_revision.err := SQLERRM ();
        END;

        BEGIN
            SELECT status
              INTO v_revision.status
              FROM all_objects
             WHERE object_name = p_name 
                AND object_type = p_type
                AND owner = USER;
        EXCEPTION
            WHEN OTHERS THEN
                v_revision.err := v_revision.err || SQLERRM ();
        END;

        --ievietojam arhīvā veco kodu
        INSERT INTO plsql_archive
             VALUES v_revision;
    END backup;
END plsql_backup;
/
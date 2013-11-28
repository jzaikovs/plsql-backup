CREATE OR REPLACE PACKAGE plsql_backup
AS
    /*
        The MIT License (MIT)
        Copyright (c) 2013 Jānis Zaikovs
    */
    -- Procedūra kas tiek izsaukta pie objektu pārkompilācijas pateicoties shēmas trigerim
    PROCEDURE backup (p_name        IN plsql_archive.name%TYPE,
                      p_type        IN plsql_archive.type%TYPE,
                      p_owner       IN plsql_archive.owner%TYPE,
                      p_new_src     IN plsql_archive.new_src%TYPE);

    PROCEDURE log (p_sql plsql_archive.new_src%TYPE, p_type plsql_archive.TYPE%TYPE);
END plsql_backup;
/

CREATE OR REPLACE PACKAGE BODY plsql_backup
AS
    /*
        The MIT License (MIT)
        Copyright (c) 2013 Jānis Zaikovs
    */
   
    -- Procedūra SQL auditiem.
    PROCEDURE log (p_sql plsql_archive.new_src%TYPE, p_type plsql_archive.type%TYPE)
    AS
        v_revision   plsql_archive%ROWTYPE;
    BEGIN
        v_revision.type := p_type;
        v_revision.created := SYSDATE;
        v_revision.new_src := p_sql;
        v_revision.osuser := SYS_CONTEXT ('USERENV', 'OS_USER');
        v_revision.ip := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');

        INSERT INTO plsql_archive
             VALUES v_revision;
    END;

    -- Funkcija objekta koda iegūšanai.
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

    -- Funkcija versijas arhivēšanai
    PROCEDURE backup (p_name        IN plsql_archive.name%TYPE,
                      p_type        IN plsql_archive.type%TYPE,
                      p_owner       IN plsql_archive.owner%TYPE,
                      p_new_src     IN plsql_archive.new_src%TYPE)
    IS
        v_revision   plsql_archive%ROWTYPE;
    BEGIN
        v_revision.name := p_name;
        v_revision.type := p_type;
        v_revision.owner := p_owner;
        v_revision.created := SYSDATE;
        v_revision.err := '';
        v_revision.osuser := SYS_CONTEXT ('USERENV', 'OS_USER');
        v_revision.ip := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        v_revision.new_src := p_new_src;        

        BEGIN
            v_revision.old_src := DBMS_METADATA.get_ddl (p_type, p_name, p_owner);
        EXCEPTION
            WHEN OTHERS THEN
                v_revision.old_src := get_code (p_name, p_type);
                v_revision.err := SQLERRM ();
        END;

        BEGIN
            SELECT status
              INTO v_revision.status
              FROM all_objects
             WHERE object_name = p_name AND object_type = p_type AND owner = USER;
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

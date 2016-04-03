CREATE OR REPLACE PACKAGE plsql_backup
AS
    /*
        The MIT License (MIT)
        Copyright (c) 2016 Jānis Zaikovs
    */
    -- Procedūra kas tiek izsaukta pie objektu pārkompilācijas pateicoties shēmas trigerim
    PROCEDURE backup (p_name        IN plsql_archive.name%TYPE,
                      p_type        IN plsql_archive.type%TYPE,
                      p_owner       IN plsql_archive.owner%TYPE,
                      p_new_src     IN plsql_archive.new_src%TYPE,
                      p_action      IN plsql_archive.action%TYPE);
END plsql_backup;
/

CREATE OR REPLACE PACKAGE BODY plsql_backup
AS
    /*
        The MIT License (MIT)
        Copyright (c) 2016 Jānis Zaikovs
    */

    -- Funkcija objekta koda iegūšanai.
    FUNCTION get_code (p_name IN VARCHAR2, p_type IN VARCHAR2)
        RETURN CLOB
    IS
        v_code   CLOB := '';
    BEGIN
        FOR src IN (  SELECT text
                        FROM user_source
                       WHERE name = p_name AND type = p_type
                    ORDER BY line ASC)
        LOOP
            v_code := v_code || src.text;
        END LOOP;

        RETURN v_code;
    END get_code;

    -- Funkcija versijas arhivēšanai
    PROCEDURE backup (p_name      IN plsql_archive.name%TYPE,
                      p_type      IN plsql_archive.type%TYPE,
                      p_owner     IN plsql_archive.owner%TYPE,
                      p_new_src   IN plsql_archive.new_src%TYPE,
                      p_action    IN plsql_archive.action%TYPE)
    IS
        r_rev   plsql_archive%ROWTYPE;
        v_type  plsql_archive.type%TYPE;
    BEGIN
        r_rev.name := p_name;
        r_rev.type := p_type;
        r_rev.owner := p_owner;
        r_rev.created := SYSDATE;
        r_rev.err := '';
        r_rev.osuser := SYS_CONTEXT ('USERENV', 'OS_USER');
        r_rev.ip := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        r_rev.new_src := p_new_src;
        r_rev.id := seq_plsql_archive.nextval;     
        r_rev.action := p_action;
        
        v_type := r_rev.type;
        IF v_type = 'PACKAGE' THEN 
            v_type := 'PACKAGE_SPEC';
        END IF;
                
        BEGIN
            r_rev.old_src := DBMS_METADATA.get_ddl (REPLACE (v_type, ' ', '_'), r_rev.name, r_rev.owner);
        EXCEPTION
            WHEN OTHERS THEN
                r_rev.old_src := get_code (r_rev.name, r_rev.type);
                r_rev.err := SQLERRM ();
        END;

        BEGIN
            SELECT status
              INTO r_rev.status
              FROM all_objects
             WHERE object_name = r_rev.name AND object_type = r_rev.type AND owner = r_rev.owner;
        EXCEPTION
            WHEN OTHERS THEN
                r_rev.err := r_rev.err || SQLERRM ();
        END;

        -- veicam koda salīdzīnāšanu ar iepriekšējo revīziju, ja kods ir nav mainījies tad reviziju nesaglabāt
        -- todo: varētu realizēt ideju, ka tikai diff ar iepriekšējo revīziju tiek saglabāts
        FOR i IN (  SELECT *
                      FROM plsql_archive
                     WHERE name = r_rev.name AND type = r_rev.type AND owner = r_rev.owner
                  ORDER BY created DESC)
        LOOP
            IF DBMS_LOB.compare (i.old_src, r_rev.old_src) = 0 THEN
                RETURN;
            END IF;

            EXIT;
        END LOOP;

        INSERT INTO plsql_archive VALUES r_rev;
    END backup;
END plsql_backup;
/
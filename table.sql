CREATE TABLE plsql_archive
(
    name      VARCHAR2 (128 BYTE),
    TYPE      VARCHAR2 (20 BYTE),
    owner     VARCHAR2 (100 BYTE),
    created   DATE,
    status    VARCHAR2 (7 BYTE),
    old_src   CLOB,
    new_src   CLOB,
    err       VARCHAR2 (4000 BYTE),
    osuser    VARCHAR2 (254 BYTE),
    ip        VARCHAR2 (20 BYTE)
);
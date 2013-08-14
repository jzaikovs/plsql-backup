CREATE TABLE plsql_archive
(
    name      VARCHAR2 (128 BYTE) NULL,
    type      VARCHAR2 (20 BYTE) NULL,
    owner     VARCHAR2(100) NULL,
    created   DATE NULL,
    status    VARCHAR2 (7 BYTE) NULL,
    old_src   CLOB NULL,
    new_src   CLOB NULL,
    err       VARCHAR2 (4000 BYTE) NULL,
    osuser    VARCHAR2 (254 BYTE) NULL,
    ip        VARCHAR2 (20 BYTE) NULL
)
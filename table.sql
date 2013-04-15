CREATE TABLE plsql_archive
(
    name       VARCHAR2 (128 BYTE) NULL,
    TYPE       VARCHAR2 (19 BYTE) NULL,
    owner      VARCHAR2 (32 BYTE) NULL,
    created    DATE NULL,
    status     VARCHAR2 (7 BYTE) NULL,
    src        CLOB NULL,
    comments   VARCHAR2 (4000 BYTE) NULL,
    osuser     VARCHAR2 (254 BYTE) NULL,
    ip         VARCHAR2 (20 BYTE) NULL
);
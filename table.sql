CREATE SEQUENCE seq_plsql_archive;

CREATE TABLE plsql_archive
(
    id        NUMBER,
    name      VARCHAR2(128),
    type      VARCHAR2(20),
    owner     VARCHAR2(100),
    created   DATE,
    status    VARCHAR2(10),
    old_src   CLOB,
    new_src   CLOB,
    err       VARCHAR2(4000),
    osuser    VARCHAR2(254),
    ip        VARCHAR2(20),
    action    VARCHAR2(32)
);

alter table plsql_archive add constraint pk_plsql_archive primary key(id);

create index idx_plsql_archive on plsql_archive(name, type, owner);
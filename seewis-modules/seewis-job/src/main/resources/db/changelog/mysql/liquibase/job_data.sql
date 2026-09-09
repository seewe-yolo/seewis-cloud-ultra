--liquibase formatted sql

--changeset seewis:job-mysql-data-baseline dbms:mysql splitStatements:true
INSERT INTO `sj_namespace` VALUES (1, 'Development', 'dev', '', 0, now(), now());

INSERT INTO `sj_namespace` VALUES (2, 'Production', 'prod', '', 0, now(), now());

INSERT INTO `sj_group_config` VALUES (1, 'dev', 'ruoyi_group', '', 'SJ_cKqBTPzCsWA3VyuCfFoccmuIEGXjr5KT', 1, 1, 0, 1, 1,  now(), now());

INSERT INTO `sj_group_config` VALUES (2, 'prod', 'ruoyi_group', '', 'SJ_cKqBTPzCsWA3VyuCfFoccmuIEGXjr5KT', 1, 1, 0, 1, 1,  now(), now());

INSERT INTO `sj_system_user` (username, password, role)
VALUES ('admin', '465c194afb65670f38322df087f0a9bb225cc257e43eb4ac5a0c98ef5b3173ac', 2);

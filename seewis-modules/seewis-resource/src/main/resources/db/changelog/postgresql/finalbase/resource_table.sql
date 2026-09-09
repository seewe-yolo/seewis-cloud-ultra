--liquibase formatted sql

--changeset seewis:resource-postgresql-table-baseline dbms:postgresql splitStatements:false
-- ### 消息记录表
create table if not exists sys_message
(
    message_id    int8,
    category      varchar(20)   not null,
    type          varchar(20)   not null,
    source        varchar(20)   not null,
    title         varchar(100)  default ''::varchar,
    message       varchar(500)  default ''::varchar,
    content       text,
    data_json     text,
    path          varchar(500)  default null::varchar,
    send_user_ids varchar(2000) not null default '0'::varchar,
    create_dept   int8,
    create_by     int8,
    create_time   timestamp,
    update_by     int8,
    update_time   timestamp,
    constraint sys_message_pk primary key (message_id)
);

create index if not exists idx_sys_message_category_time on sys_message (category, create_time);

comment on table sys_message                   is '消息记录表';
comment on column sys_message.message_id       is '消息ID';
comment on column sys_message.category         is '消息分组(system/notice/workflow)';
comment on column sys_message.type             is '消息类型';
comment on column sys_message.source           is '消息来源';
comment on column sys_message.title            is '标题';
comment on column sys_message.message          is '摘要消息';
comment on column sys_message.content          is '详细内容';
comment on column sys_message.data_json        is '扩展数据JSON';
comment on column sys_message.path             is '前端跳转路径';
comment on column sys_message.send_user_ids    is '目标用户ID串，0表示全局';
comment on column sys_message.create_dept      is '创建部门';
comment on column sys_message.create_by        is '创建者';
comment on column sys_message.create_time      is '创建时间';
comment on column sys_message.update_by        is '更新者';
comment on column sys_message.update_time      is '更新时间';

-- ### OSS对象存储表
create table if not exists sys_oss
(
    oss_id        int8,
    file_name     varchar(255) default ''::varchar not null,
    original_name varchar(255) default ''::varchar not null,
    file_suffix   varchar(10)  default ''::varchar not null,
    url           varchar(500) default ''::varchar not null,
    ext1          varchar(500) default ''::varchar,
    create_dept   int8,
    create_by     int8,
    create_time   timestamp,
    update_by     int8,
    update_time   timestamp,
    service       varchar(20)  default 'minio'::varchar,
    constraint sys_oss_pk primary key (oss_id)
);

comment on table sys_oss                    is 'OSS对象存储表';
comment on column sys_oss.oss_id            is '对象存储主键';
comment on column sys_oss.file_name         is '文件名';
comment on column sys_oss.original_name     is '原名';
comment on column sys_oss.file_suffix       is '文件后缀名';
comment on column sys_oss.url               is 'URL地址';
comment on column sys_oss.ext1              is '扩展字段';
comment on column sys_oss.create_by         is '上传人';
comment on column sys_oss.create_dept       is '创建部门';
comment on column sys_oss.create_time       is '创建时间';
comment on column sys_oss.update_by         is '更新者';
comment on column sys_oss.update_time       is '更新时间';
comment on column sys_oss.service           is '服务商';

-- ### OSS对象存储配置表
create table if not exists sys_oss_config
(
    oss_config_id int8,
    config_key    varchar(20)  default ''::varchar not null,
    access_key    varchar(255) default ''::varchar,
    secret_key    varchar(255) default ''::varchar,
    bucket_name   varchar(255) default ''::varchar,
    prefix        varchar(255) default ''::varchar,
    endpoint      varchar(255) default ''::varchar,
    domain_url    varchar(255) default ''::varchar,
    is_https      char         default 'N'::bpchar,
    region        varchar(255) default ''::varchar,
    access_policy char(1)      default '1'::bpchar not null,
    status        char         default 'N'::bpchar,
    ext1          varchar(255) default ''::varchar,
    create_dept   int8,
    create_by     int8,
    create_time   timestamp,
    update_by     int8,
    update_time   timestamp,
    remark        varchar(500) default ''::varchar,
    constraint sys_oss_config_pk primary key (oss_config_id)
);

comment on table sys_oss_config                 is '对象存储配置表';
comment on column sys_oss_config.oss_config_id  is '主键';
comment on column sys_oss_config.config_key     is '配置key';
comment on column sys_oss_config.access_key     is 'accessKey';
comment on column sys_oss_config.secret_key     is '秘钥';
comment on column sys_oss_config.bucket_name    is '桶名称';
comment on column sys_oss_config.prefix         is '前缀';
comment on column sys_oss_config.endpoint       is '访问站点';
comment on column sys_oss_config.domain_url     is '自定义域名';
comment on column sys_oss_config.is_https       is '是否https（Y=是,N=否）';
comment on column sys_oss_config.region         is '域';
comment on column sys_oss_config.access_policy  is '桶权限类型(0=private 1=public 2=custom)';
comment on column sys_oss_config.status         is '是否默认（Y=是,N=否）';
comment on column sys_oss_config.ext1           is '扩展字段';
comment on column sys_oss_config.create_dept    is '创建部门';
comment on column sys_oss_config.create_by      is '创建者';
comment on column sys_oss_config.create_time    is '创建时间';
comment on column sys_oss_config.update_by      is '更新者';
comment on column sys_oss_config.update_time    is '更新时间';
comment on column sys_oss_config.remark         is '备注';

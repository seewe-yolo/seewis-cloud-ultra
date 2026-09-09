--liquibase formatted sql

--changeset seewis:resource-mysql-table-baseline dbms:mysql splitStatements:true
-- ### 消息记录表
create table sys_message (
    message_id        bigint(20)      not null                   comment '消息ID',
    category          varchar(20)     not null                   comment '消息分组(system/notice/workflow)',
    type              varchar(20)     not null                   comment '消息类型',
    source            varchar(20)     not null                   comment '消息来源',
    title             varchar(100)    default ''                 comment '标题',
    message           varchar(500)    default ''                 comment '摘要消息',
    content           longtext                                   comment '详细内容',
    data_json         longtext                                   comment '扩展数据JSON',
    path              varchar(500)    default null               comment '前端跳转路径',
    send_user_ids     varchar(2000)   not null default '0'       comment '目标用户ID串，0表示全局',
    create_dept       bigint(20)      default null               comment '创建部门',
    create_by         bigint(20)      default null               comment '创建者',
    create_time       datetime                                   comment '创建时间',
    update_by         bigint(20)      default null               comment '更新者',
    update_time       datetime                                   comment '更新时间',
    primary key (message_id),
    key idx_sys_message_category_time (category, create_time)
) engine=innodb comment = '消息记录表';

-- ### OSS对象存储表
create table sys_oss (
  oss_id          bigint(20)   not null                   comment '对象存储主键',
  file_name       varchar(255) not null default ''        comment '文件名',
  original_name   varchar(255) not null default ''        comment '原名',
  file_suffix     varchar(10)  not null default ''        comment '文件后缀名',
  url             varchar(500) not null                   comment 'URL地址',
  ext1            text                  default null      comment '扩展字段',
  create_dept     bigint(20)            default null      comment '创建部门',
  create_time     datetime              default null      comment '创建时间',
  create_by       bigint(20)            default null      comment '上传人',
  update_time     datetime              default null      comment '更新时间',
  update_by       bigint(20)            default null      comment '更新人',
  service         varchar(20)  not null default 'minio'   comment '服务商',
  primary key (oss_id)
) engine=innodb comment ='OSS对象存储表';

-- ### OSS对象存储配置表
create table sys_oss_config (
  oss_config_id   bigint(20)    not null                  comment '主键',
  config_key      varchar(20)   not null  default ''      comment '配置key',
  access_key      varchar(255)            default ''      comment 'accessKey',
  secret_key      varchar(255)            default ''      comment '秘钥',
  bucket_name     varchar(255)            default ''      comment '桶名称',
  prefix          varchar(255)            default ''      comment '前缀',
  endpoint        varchar(255)            default ''      comment '访问站点',
  domain_url      varchar(255)            default ''      comment '自定义域名',
  is_https        char(1)                 default 'N'     comment '是否https（Y=是,N=否）',
  region          varchar(255)            default ''      comment '域',
  access_policy   char(1)       not null  default '1'     comment '桶权限类型(0=private 1=public 2=custom)',
  status          char(1)                 default 'N'     comment '是否默认（Y=是,N=否）',
  ext1            varchar(255)            default ''      comment '扩展字段',
  create_dept     bigint(20)              default null    comment '创建部门',
  create_by       bigint(20)              default null    comment '创建者',
  create_time     datetime                default null    comment '创建时间',
  update_by       bigint(20)              default null    comment '更新者',
  update_time     datetime                default null    comment '更新时间',
  remark          varchar(500)            default null    comment '备注',
  primary key (oss_config_id)
) engine=innodb comment='对象存储配置表';

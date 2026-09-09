--liquibase formatted sql

--changeset seewis:system-mysql-table-baseline dbms:mysql splitStatements:true
-- ### 社会化关系表：第三方平台授权与用户关联信息
create table sys_social
(
    id                 bigint           not null        comment '主键',
    user_id            bigint           not null        comment '用户ID',
    auth_id            varchar(255)     not null        comment '平台+平台唯一id',
    source             varchar(255)     not null        comment '用户来源',
    open_id            varchar(255)     default null    comment '平台编号唯一id',
    user_name          varchar(30)      not null        comment '登录账号',
    nick_name          varchar(30)      default ''      comment '用户昵称',
    email              varchar(255)     default ''      comment '用户邮箱',
    avatar             varchar(500)     default ''      comment '头像地址',
    access_token       varchar(2000)     not null        comment '用户的授权令牌',
    expire_in          int              default null    comment '用户的授权令牌的有效期，部分平台可能没有',
    refresh_token      varchar(2000)     default null    comment '刷新令牌，部分平台可能没有',
    access_code        varchar(255)     default null    comment '平台的授权信息，部分平台可能没有',
    union_id           varchar(255)     default null    comment '用户的 unionid',
    scope              varchar(255)     default null    comment '授予的权限，部分平台可能没有',
    token_type         varchar(255)     default null    comment '个别平台的授权信息，部分平台可能没有',
    id_token           varchar(2000)    default null    comment 'id token，部分平台可能没有',
    mac_algorithm      varchar(255)     default null    comment '小米平台用户的附带属性，部分平台可能没有',
    mac_key            varchar(255)     default null    comment '小米平台用户的附带属性，部分平台可能没有',
    code               varchar(255)     default null    comment '用户的授权code，部分平台可能没有',
    oauth_token        varchar(255)     default null    comment 'Twitter平台用户的附带属性，部分平台可能没有',
    oauth_token_secret varchar(255)     default null    comment 'Twitter平台用户的附带属性，部分平台可能没有',
    create_dept        bigint(20)                       comment '创建部门',
    create_by          bigint(20)                       comment '创建者',
    create_time        datetime                         comment '创建时间',
    update_by          bigint(20)                       comment '更新者',
    update_time        datetime                         comment '更新时间',
    del_flag           char(1)          default '0'     comment '删除标志（0代表存在 1代表删除）',
    PRIMARY KEY (id)
) engine=innodb comment = '社会化关系表';
-- ### 部门表
create table sys_dept (
  dept_id           bigint(20)      not null                   comment '部门id',
  parent_id         bigint(20)      default 0                  comment '父部门id',
  ancestors         varchar(500)    default ''                 comment '祖级列表',
  dept_name         varchar(30)     default ''                 comment '部门名称',
  dept_category     varchar(100)    default null               comment '部门类别编码',
  order_num         int(4)          default 0                  comment '显示顺序',
  leader            bigint(20)      default null               comment '负责人',
  phone             varchar(11)     default null               comment '联系电话',
  email             varchar(50)     default null               comment '邮箱',
  status            char(1)         default '0'                comment '部门状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 1代表删除）',
  create_dept       bigint(20)      default null               comment '创建部门',
  create_by         bigint(20)      default null               comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         bigint(20)      default null               comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (dept_id),
  key idx_sys_dept_parent_id (parent_id)
) engine=innodb comment = '部门表';
-- ### 用户表
create table sys_user (
  user_id           bigint(20)      not null                   comment '用户ID',
  dept_id           bigint(20)      default null               comment '部门ID',
  user_name         varchar(30)     not null                   comment '用户账号',
  nick_name         varchar(30)     not null                   comment '用户昵称',
  user_type         varchar(10)     default 'sys_user'         comment '用户类型（sys_user系统用户）',
  email             varchar(50)     default ''                 comment '用户邮箱',
  phone_number      varchar(11)     default ''                 comment '手机号码',
  gender            char(1)         default '0'                comment '用户性别（0男 1女 2未知）',
  avatar            bigint(20)                                 comment '头像地址',
  password          varchar(100)    default ''                 comment '密码',
  status            char(1)         default '0'                comment '账号状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 1代表删除）',
  login_ip          varchar(128)    default ''                 comment '最后登录IP',
  login_date        datetime                                   comment '最后登录时间',
  create_dept       bigint(20)      default null               comment '创建部门',
  create_by         bigint(20)      default null               comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         bigint(20)      default null               comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (user_id),
  key idx_sys_user_dept_id   (dept_id),
  key idx_sys_user_create_by (create_by),
  key idx_sys_user_user_name (user_name),
  key idx_sys_user_phone     (phone_number)
) engine=innodb comment = '用户信息表';
-- ### 岗位表
create table sys_post
(
  post_id       bigint(20)      not null                   comment '岗位ID',
  dept_id       bigint(20)      not null                   comment '部门id',
  post_code     varchar(64)     not null                   comment '岗位编码',
  post_category varchar(100)    default null               comment '岗位类别编码',
  post_name     varchar(50)     not null                   comment '岗位名称',
  post_sort     int(4)          not null                   comment '显示顺序',
  status        char(1)         not null                   comment '状态（0正常 1停用）',
  del_flag      char(1)         default '0'                comment '删除标志（0代表存在 1代表删除）',
  create_dept   bigint(20)      default null               comment '创建部门',
  create_by     bigint(20)      default null               comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     bigint(20)      default null               comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (post_id),
  key idx_sys_post_dept_id (dept_id)
) engine=innodb comment = '岗位信息表';
-- ### 角色表
create table sys_role (
  role_id              bigint(20)      not null                   comment '角色ID',
  role_name            varchar(30)     not null                   comment '角色名称',
  role_key             varchar(100)    not null                   comment '角色权限字符串',
  role_sort            int(4)          not null                   comment '显示顺序',
  data_scope           char(1)         default '1'                comment '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：仅本人数据权限 6：部门及以下或本人数据权限）',
  menu_check_strictly  tinyint(1)      default 1                  comment '菜单树选择项是否关联显示',
  dept_check_strictly  tinyint(1)      default 1                  comment '部门树选择项是否关联显示',
  status               char(1)         not null                   comment '角色状态（0正常 1停用）',
  del_flag             char(1)         default '0'                comment '删除标志（0代表存在 1代表删除）',
  create_dept          bigint(20)      default null               comment '创建部门',
  create_by            bigint(20)      default null               comment '创建者',
  create_time          datetime                                   comment '创建时间',
  update_by            bigint(20)      default null               comment '更新者',
  update_time          datetime                                   comment '更新时间',
  remark               varchar(500)    default null               comment '备注',
  primary key (role_id),
  key idx_sys_role_create_dept (create_dept),
  key idx_sys_role_create_by   (create_by)
) engine=innodb comment = '角色信息表';
-- ### 菜单权限表
create table sys_menu (
  menu_id           bigint(20)      not null                   comment '菜单ID',
  menu_name         varchar(50)     not null                   comment '菜单名称',
  parent_id         bigint(20)      default 0                  comment '父菜单ID',
  order_num         int(4)          default 0                  comment '显示顺序',
  path              varchar(200)    default ''                 comment '路由地址',
  component         varchar(255)    default null               comment '组件路径',
  query_param       varchar(255)    default null               comment '路由参数',
  is_frame          char(1)         default 'N'                comment '是否为外链（Y是 N否）',
  is_cache          char(1)         default 'Y'                comment '是否缓存（Y缓存 N不缓存）',
  menu_type         char(1)         default ''                 comment '菜单类型（M目录 C菜单 F按钮）',
  visible           char(1)         default 0                  comment '显示状态（0显示 1隐藏）',
  status            char(1)         default 0                  comment '菜单状态（0正常 1停用）',
  perms             varchar(100)    default null               comment '权限标识',
  icon              varchar(100)    default '#'                comment '菜单图标',
  active_menu       varchar(255)    default ''                 comment '激活菜单路径',
  ext               varchar(2000)   default ''                 comment '扩展字段',
  create_dept       bigint(20)      default null               comment '创建部门',
  create_by         bigint(20)      default null               comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         bigint(20)      default null               comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default ''                 comment '备注',
  primary key (menu_id)
) engine=innodb comment = '菜单权限表';
-- ### 用户角色关联表
create table sys_user_role (
  user_id   bigint(20) not null comment '用户ID',
  role_id   bigint(20) not null comment '角色ID',
  primary key(user_id, role_id),
  key idx_sys_user_role_rid (role_id)
) engine=innodb comment = '用户和角色关联表';
-- ### 角色菜单关联表
create table sys_role_menu (
  role_id   bigint(20) not null comment '角色ID',
  menu_id   bigint(20) not null comment '菜单ID',
  primary key(role_id, menu_id)
) engine=innodb comment = '角色和菜单关联表';
-- ### 角色部门关联表
create table sys_role_dept (
  role_id   bigint(20) not null comment '角色ID',
  dept_id   bigint(20) not null comment '部门ID',
  primary key(role_id, dept_id)
) engine=innodb comment = '角色和部门关联表';
-- ### 用户岗位关联表
create table sys_user_post
(
  user_id   bigint(20) not null comment '用户ID',
  post_id   bigint(20) not null comment '岗位ID',
  primary key (user_id, post_id)
) engine=innodb comment = '用户与岗位关联表';
-- ### 操作日志表
create table sys_oper_log (
  oper_id           bigint(20)      not null                   comment '日志主键',
  title             varchar(50)     default ''                 comment '模块标题',
  business_type     int(2)          default 0                  comment '业务类型（0其它 1新增 2修改 3删除）',
  method            varchar(100)    default ''                 comment '方法名称',
  request_method    varchar(10)     default ''                 comment '请求方式',
  operator_type     int(1)          default 0                  comment '操作类别（0其它 1后台用户 2手机端用户）',
  oper_name         varchar(50)     default ''                 comment '操作人员',
  user_id           bigint(20)      default null               comment '操作用户ID',
  dept_id           bigint(20)      default null               comment '操作部门ID',
  dept_name         varchar(50)     default ''                 comment '部门名称',
  client_key        varchar(32)     default ''                 comment '客户端',
  device_type       varchar(32)     default ''                 comment '设备类型',
  browser           varchar(50)     default ''                 comment '浏览器类型',
  os                varchar(50)     default ''                 comment '操作系统',
  oper_url          varchar(255)    default ''                 comment '请求URL',
  oper_ip           varchar(128)    default ''                 comment '主机地址',
  oper_location     varchar(255)    default ''                 comment '操作地点',
  oper_param        varchar(4000)   default ''                 comment '请求参数',
  json_result       varchar(4000)   default ''                 comment '返回参数',
  status            int(1)          default 0                  comment '操作状态（0正常 1异常）',
  error_msg         varchar(4000)   default ''                 comment '错误消息',
  oper_time         datetime                                   comment '操作时间',
  cost_time         bigint(20)      default 0                  comment '消耗时间',
  primary key (oper_id),
  key idx_sys_oper_log_bt (business_type),
  key idx_sys_oper_log_uid (user_id),
  key idx_sys_oper_log_s  (status),
  key idx_sys_oper_log_ot (oper_time)
) engine=innodb comment = '操作日志记录';
-- ### 字典类型表
create table sys_dict_type
(
  dict_id          bigint(20)      not null                   comment '字典主键',
  dict_name        varchar(100)    default ''                 comment '字典名称',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  create_dept      bigint(20)      default null               comment '创建部门',
  create_by        bigint(20)      default null               comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        bigint(20)      default null               comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_id),
  unique (dict_type)
) engine=innodb comment = '字典类型表';
-- ### 字典数据表
create table sys_dict_data
(
  dict_code        bigint(20)      not null                   comment '字典编码',
  dict_sort        int(4)          default 0                  comment '字典排序',
  dict_label       varchar(100)    default ''                 comment '字典标签',
  dict_value       varchar(100)    default ''                 comment '字典键值',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  css_class        varchar(100)    default null               comment '样式属性（其他样式扩展）',
  list_class       varchar(100)    default null               comment '表格回显样式',
  is_default       char(1)         default 'N'                comment '是否默认（Y是 N否）',
  create_dept      bigint(20)      default null               comment '创建部门',
  create_by        bigint(20)      default null               comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        bigint(20)      default null               comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_code),
  key idx_sys_dict_data_type (dict_type)
) engine=innodb comment = '字典数据表';
-- ### 参数配置表
create table sys_config (
  config_id         bigint(20)      not null                   comment '参数主键',
  config_name       varchar(100)    default ''                 comment '参数名称',
  config_key        varchar(100)    default ''                 comment '参数键名',
  config_value      varchar(500)    default ''                 comment '参数键值',
  config_type       char(1)         default 'N'                comment '系统内置（Y是 N否）',
  create_dept       bigint(20)      default null               comment '创建部门',
  create_by         bigint(20)      default null               comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         bigint(20)      default null               comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (config_id)
) engine=innodb comment = '参数配置表';
-- ### 登录日志表
create table sys_login_info (
  info_id        bigint(20)     not null                  comment '访问ID',
  user_name      varchar(50)    default ''                comment '用户账号',
  client_key     varchar(32)    default ''                comment '客户端',
  device_type    varchar(32)    default ''                comment '设备类型',
  ipaddr         varchar(128)   default ''                comment '登录IP地址',
  login_location varchar(255)   default ''                comment '登录地点',
  browser        varchar(50)    default ''                comment '浏览器类型',
  os             varchar(50)    default ''                comment '操作系统',
  status         char(1)        default '0'               comment '登录状态（0正常 1异常）',
  msg            varchar(255)   default ''                comment '提示消息',
  login_time     datetime                                 comment '访问时间',
  primary key (info_id),
  key idx_sys_login_info_s  (status),
  key idx_sys_login_info_lt (login_time)
) engine=innodb comment = '系统访问记录';
-- ### 通知公告表
create table sys_notice (
  notice_id         bigint(20)      not null                   comment '公告ID',
  notice_title      varchar(50)     not null                   comment '公告标题',
  notice_type       char(1)         not null                   comment '公告类型（1通知 2公告）',
  notice_content    longblob        default null               comment '公告内容',
  status            char(1)         default '0'                comment '公告状态（0正常 1关闭）',
  create_dept       bigint(20)      default null               comment '创建部门',
  create_by         bigint(20)      default null               comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         bigint(20)      default null               comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(255)    default null               comment '备注',
  primary key (notice_id)
) engine=innodb comment = '通知公告表';
-- ### 客户端授权表
create table sys_client (
    id                  bigint(20)    not null            comment 'id',
    client_id           varchar(64)   default null        comment '客户端id',
    client_key          varchar(32)   default null        comment '客户端key',
    client_secret       varchar(255)  default null        comment '客户端秘钥',
    grant_type          varchar(255)  default null        comment '授权类型',
    device_type         varchar(32)   default null        comment '设备类型',
    access_path         varchar(1024) default null        comment '允许访问路径',
    ip_whitelist        varchar(1024) default null        comment 'IP白名单',
    active_timeout      int(11)       default 1800        comment 'token活跃超时时间',
    timeout             int(11)       default 604800      comment 'token固定超时',
    status              char(1)       default '0'         comment '状态（0正常 1停用）',
    del_flag            char(1)       default '0'         comment '删除标志（0代表存在 1代表删除）',
    create_dept         bigint(20)    default null        comment '创建部门',
    create_by           bigint(20)    default null        comment '创建者',
    create_time         datetime      default null        comment '创建时间',
    update_by           bigint(20)    default null        comment '更新者',
    update_time         datetime      default null        comment '更新时间',
    primary key (id)
) engine=innodb comment='系统授权表';
-- ### Seata AT事务回滚日志表
CREATE TABLE IF NOT EXISTS undo_log
(
    branch_id     BIGINT(20)   NOT NULL COMMENT 'branch transaction id',
    xid           VARCHAR(100) NOT NULL COMMENT 'global transaction id',
    context       VARCHAR(128) NOT NULL COMMENT 'undo_log context,such as serialization',
    rollback_info LONGBLOB     NOT NULL COMMENT 'rollback info',
    log_status    INT(11)      NOT NULL COMMENT '0:normal status,1:defense status',
    log_created   DATETIME(6)  NOT NULL COMMENT 'create datetime',
    log_modified  DATETIME(6)  NOT NULL COMMENT 'modify datetime',
    UNIQUE KEY ux_undo_log (xid, branch_id)
) ENGINE = InnoDB COMMENT ='AT transaction mode undo table';

/*
Navicat MySQL Data Transfer

Source Server         : 192.168.100.102
Source Server Version : 50613
Source Host           : 192.168.100.102:3306
Source Database       : autotask

Target Server Type    : MYSQL
Target Server Version : 50613
File Encoding         : 65001

Date: 2015-06-03 17:49:30
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `pre_host_zzb`
-- ----------------------------
DROP TABLE IF EXISTS `pre_host_zzb`;
CREATE TABLE `pre_host_zzb` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `depart_name` varchar(64) NOT NULL COMMENT '分区名称',
  `server_name` varchar(128) DEFAULT NULL COMMENT '服务器名称或域名',
  `groupby` varchar(128) DEFAULT NULL COMMENT '分组名称',
  `network_ip` varchar(15) NOT NULL COMMENT '内网IP',
  `cpu` varchar(64) DEFAULT NULL COMMENT 'CPU',
  `mem` varchar(64) DEFAULT NULL COMMENT '内存',
  `disk` varchar(64) DEFAULT NULL COMMENT '数据盘',
  `pro_type` varchar(64) DEFAULT '' COMMENT '应用类型',
  `config_dir` varchar(164) DEFAULT '' COMMENT '配置目录',
  `pro_dir` varchar(164) DEFAULT NULL COMMENT '工程目录',
  `log_dir` varchar(164) DEFAULT NULL COMMENT '日志路径',
  `pro_key` varchar(64) DEFAULT NULL COMMENT '进程关键词',
  `pro_init` varchar(100) DEFAULT NULL COMMENT '启动脚本',
  `pro_port` varchar(255) DEFAULT NULL COMMENT '启动端口',
  `system_type` varchar(64) DEFAULT NULL COMMENT '操作系统',
  `created_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime DEFAULT NULL COMMENT '更新记录的时间',
  `status` varchar(64) DEFAULT '启用' COMMENT '状态',
  `note` varchar(128) DEFAULT NULL COMMENT '备注',
  `mask` int(12) DEFAULT NULL COMMENT '唯一标志位',
  `local_name` varchar(200) DEFAULT NULL COMMENT '识别名称',
  `app_key` varchar(200) DEFAULT NULL COMMENT '应用唯一关键词',
  `is_deloy_dir` varchar(64) DEFAULT NULL COMMENT '发布目录判断',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of pre_host_zzb
-- ----------------------------
INSERT INTO `pre_host_zzb` VALUES (1, '『 基础分区 』', '基础测试应用一', 'base', '192.168.100.21', '1核', '2G', '108G', 'tomcat', '/data/www/html/WEB-INF', '/data/www/html', '/data/log/tomcat', 'tomcat', '/etc/init.d/tomcat', 'tomcat-java:127.0.0.1:8005<br>tomcat-java:null:8009<br>tomcat-java:null:8080<br>tomcat-java:null:443', '', '2014-11-12 10:16:28', '2014-11-12 10:16:28', '启用', '', 0, 'ssogo', 'ssogo', '1');
INSERT INTO `pre_host_zzb` VALUES (2, '『 基础分区 』', '基础测试应用三', 'base', '192.168.100.72', '1核', '2G', '54G', 'resin', '/data/www/ins_share', '/data/www/html', '/data/log/resin', 'resin', '/etc/init.d/resin ', 'resin-java:null:8080', '', '2014-11-12 10:16:28', '2014-11-12 10:16:28', '启用', '', 0, 'auth', 'auth', '2');
INSERT INTO `pre_host_zzb` VALUES (3, '『 三区 』', '三分区测试应用一', 'depart3', '192.168.100.26', '1核', '6G', '54G', 'resin', '/data/www/ins_share', '/data/www/html', '/data/log/resin', 'resin', '/etc/init.d/resin', 'rb-java:192.168.100.26:9995<br>rb-java:null:8080<br>rb-java:null:33629', '', '2014-11-12 10:16:28', '2014-11-12 10:16:28', '启用', '', 0, 'rb', 'rb3', '2');
INSERT INTO `pre_host_zzb` VALUES (4, '『 三区 』', '三分区测试应用二 ', 'depart3', '192.168.100.52', '1核', '2G', '22G', 'apps', '/data/www/apps/order-service-server/config', '/data/www/apps/order-service-server', '/data/log/apps/order-service-server', 'order-service-server', '/etc/init.d/order', 'order-service-server-java:null:43783<br>order-service-server-java:192.168.100.52:6543', '', '2014-11-12 10:16:28', '2014-11-12 10:16:28', '启用', '', 0, 'order', 'order3', '1');

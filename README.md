#RexDeploy-自动发布系统


#一、简介
RexDeploy是基于Rex开发的一个自动化发布平台。（原生是基于perl脚本构建的,这是第一版,后续会捣鼓出python版和web版本支持）

     
#二、安装需求

	* Rex 
	* DBI（perl模块）
	* DBD-mysql (perl模块)

(运行Linux系统之上)

一键安装方法:(Centos 5.5 和Centos 6.3测试OK)
```
unzip  RexDeploy.zip
cd RexDeploy/install
/bin/bash  install.sh
```
安装数据库过程省略,建立autask数据库,手工导入pre_host_zzb.sql,并按照如下提示做好配置。

配置：
进入到安装目录/data/RexDeploy

①配置远程服务器的通用账号和密码: Rexfile
其他配置项,缺省即可。

②配置数据库配置: RexDeploy/lib/Deploy/Db/__module__.pm

其他配置请见: RexDeploy/lib/Deploy/Core/__module__.pm 采用默认即可。




#三、目录层级解释

tree -L 2
```
├── backup  (临时备份目录)
├── config    (配置文件目录)
│   ├── config.ini  (配置常用的配置:暂未使用,后续整合)
│   └── ip_lists.ini  (IP分组列表)
├── configuredir (发布前的配置目录)
├── lib     (模块目录)
│   ├── Common  (自定义公共模块)
│   ├── Deploy   (自定义发布模块)
│   └── Rex (官放手动安装模块)
├── logs  (日志目录)
├── remotecomdir  (从远程服务器下载后的目录)
├── Rexfile  (rex主程序入口)
├── softdir  (发布前的工程目录)
└── install (安装目录)
    ├── DBD-mysql-4.031.tar.gz
    ├── DBI-1.633.tar.gz
    └── install.sh
14 directories, 6 files
对于使用者只要关注 configuredir  softdir . 
```

#四、自动发布原理图
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/111956_5ff56ef3_119746.png "在这里输入图片标题")

#五、数据库表字段约束和解释

从以上的发布流程图也可以知道,整个发布的流程是以在数据库表中的规则为主,比如工程路径,启动脚本等。

表字段的详细介绍如下:
```
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
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8
```

上面是一台服务器的基本信息记录表, 那么我着重只讲和发布相关的几个重要字段。其字段如下。

"id","app_key","server_name","network_ip","pro_type","config_dir","pro_dir","pro_key","pro_init","local_name","is_deloy_dir"
```
app_key: 应用发布的唯一关键词,不能有重复,不能为空,如果为空,则不会加入到自动发布的系统里面。

pro_key: 进程关键字最好选择的唯一的关键词,在关闭应用失败的时候,会通过应用关键词去KILL应用

pro_init: 启动脚本必须是在/etc/init.d/下面的脚本,不然可能会启动失败。

is_deloy_dir: 发布目录判断
=>2代表工程路径和配置路径是隔离开来的,比如:cm的工程路径为: /data/www/html 配置路径为: /data/www/ins_share 
=>1代表 工程路径和配置路径是合在一起的比如task-dispatcher,它的工程路径为/data/www/apps/task-dispatcher,配置路径为: /data/www/apps/task-dispatcher/conf

local_name: 应用发布初始目录的名字,比如 cm3系统设置的local_name为cm,且is_deloy_dir为2,那么发布的初始目录为: 工程路径:$softdir/cm 配置路径为: $configure/cm3
```

#六、执行发布

先上发布图：比如我要发布tpic3 (此次发布替换class文件)

第一步，进入到工程目录替换class
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114510_1c3c456b_119746.png "在这里输入图片标题")

第二步，直接发布
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114524_919d028c_119746.png "在这里输入图片标题")

#七.自动发布系统几大功能点介绍

**①查看帮助 rex -T**
目前暂时开发了以下的模块和功能 (左边是任务模块的名称,右边是解释和示例)
![](http://git.oschina.net/uploads/images/2015/0603/114546_902430a2_119746.png "在这里输入图片标题")

**②查看支持哪些系统的发布与操作 rex list**
(app_key是唯一的,一个key代表一个系统)
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114604_2c4b9313_119746.png "在这里输入图片标题")

**③发布多个系统： rex deploy --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6'       (以空格间隔)**

**④下载远程服务器数据(程序和配置)到本地: rex download --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6'**
（如果你要下载所有关键词的系统到本地请使用: rex download --k='all'）
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114819_c490b2ea_119746.png "在这里输入图片标题")

**⑤ 同步本地(远程download)的程序和配置=>待发布目录  rex Deploy:Core:syncpro**
执行上面的时候,自动将所有待发布的目录清空,然后将下载目录的程序同步待发布的目录中
(可以设置自动同步数据到发布目录执行语句是：   rex download --k='all'  =>rex Deploy:Core:syncpro  )
![](http://git.oschina.net/uploads/images/2015/0603/114838_cf535717_119746.png "在这里输入图片标题")
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114847_cdeb21c8_119746.png "在这里输入图片标题")

**⑥检查数据库以及远程服务器的配置 rex check --k='cm6  xampprobot6'**
(就是核对数据库中关于各个配置是否正确,比如远程服务器的工程目录/配置目录/启动脚本/进程等是否存在)
(检查所有远程服务器的信息: rex check --k='all' )
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114859_ecbac61e_119746.png "在这里输入图片标题")

**⑦批量执行命令 rex run --k='atm  cm3 carbiz3 ' --cmd='uptime'**
(如查看系统的时间: rex run --k='all' --cmd='date')
![输入图片说明](http://git.oschina.net/uploads/images/2015/0603/114907_ffbae71e_119746.png "在这里输入图片标题")
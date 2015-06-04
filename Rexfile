##author: QingFeng
##qq: 530035210
##blog: http://my.oschina.net/pwd/blog
##date: 2015-05-05
##des:应用动态发布

#开启rsync模块
use Rex::Commands::Rsync;
use Deploy::Db;
use Data::Dumper;
use Deploy::Core;
use Common::Use;
 
#密码认证方式,缺省账号、密码
user "root";
password "root123456789";
pass_auth;

#环境变量设置
source_global_profile  "1" ;

#自定义perl Config模块:  配置文件和程序隔离
#Config::IniFiles安装方法:
#perl -MCPAN -e 'install Module::Build'
#perl -MCPAN -e 'install Config::IniFiles'

#并发设置
parallelism "4";
#通过配置文件定义服务组
use Rex::Group::Lookup::INI;
#groups_file "config/ip_lists.ini";
logging to_file => "logs/rex.log";

#ssh超时时间和ssh最大的尝试次数
timeout "60" ;
max_connect_retries  "5";

path "/usr/local/mysql/bin","/usr/local/mysql/bin","/data/java/jdk/bin","/usr/local/mysql/bin","/usr/local/mysql/bin","/usr/local/mysql/bin","/data/java/jdk/bin","/usr/local/mysql/bin","/usr/kerberos/sbin","/usr/kerberos/bin","/usr/local/sbin","/usr/local/bin","/sbin","/bin","/usr/sbin","/usr/bin","/root/bin";

desc "应用发布模块: rex deploy --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6' \n";
task "deploy", sub {
   my $self = shift;
   my $k=$self->{k};
   my $keys=Deploy::Db::getallkey();
   my @keys=split(/,/, $keys);
   my %vars = map { $_ => 1 } @keys;
   my $lastnum=$keys[-1] - 1;
   if( $k eq ""  ){
   Rex::Logger::info("关键字(--k='')不能为空","error");
   exit;
   }
   my @ks = split(/ /, $k);

   Rex::Logger::info("");
   Rex::Logger::info("开始应用发布模块.");
   for my $kv (@ks) {
   if ( $kv ne "" ){
   if (exists($vars{$kv})){
   Rex::Logger::info("");
   Rex::Logger::info("##############($kv)###############");
   #初始化数据库信息
   my $config=Deploy::Core::init("$kv");
   #第一次连接获取远程服务器信息
   my $FistSerInfo=Deploy::Core::prepare($kv,$config->{'network_ip'},$config->{'pro_init'},$config->{'pro_key'},$config->{'pro_dir'},$config->{'config_dir'});
   #上传程序目录和配置目录
   my $dir=Deploy::Core::uploading($kv,$config->{'local_name'},$config->{'pro_dir'},$config->{'network_ip'},$config->{'config_dir'},$config->{'app_key'},$config->{'is_deloy_dir'},$config->{'pro_dir'},$config->{'config_dir'});	
   #更改软链接,重启应用
   run_task "Deploy:Core:linkrestart",on=>$config->{'network_ip'},params=>{ k => $kv,network_ip =>$config->{'network_ip'},ps_num=>$FistSerInfo->{'ps_num'},pro_key=>$config->{'pro_key'},pro_init=>$config->{'pro_init'},remote_prodir=>$dir->{'remote_prodir'},remote_configdir=>$dir->{'remote_configdir'},pro_dir=>$config->{'pro_dir'},config_dir=>$config->{'config_dir'},is_deloy_dir=>$config->{'is_deloy_dir'},localdir=>$dir->{'localdir'},local_config_dir=>$dir->{'local_config_dir'}};	
   }else{
   Rex::Logger::info("关键字($kv)不存在","error");
   }
   }}
   Rex::Logger::info("应用发布模块完成.");
};


desc "下载远程服务器数据到本地:rex download --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6' \n\t\t\t\t\t\t\t   rex download --k='all'";
task "download",sub{
   my $self = shift;
   my $k=$self->{k};
   my $keys=Deploy::Db::getallkey();
   my @keys=split(/,/, $keys);
   my %vars = map { $_ => 1 } @keys;
   my $lastnum=$keys[-1] - 1;
   if( $k eq ""  ){
   Rex::Logger::info("关键字(--k='')不能为空");
   exit;
   }
   my @ks = split(/ /, $k);
   if ( $k eq "all" ){
   Rex::Logger::info("");
   Rex::Logger::info("开始下载远程服务器数据到本地---$keys[-1] 个.");
   for my $num (0..$lastnum) {
   Rex::Logger::info("");
   Rex::Logger::info("##############($keys[$num])###############");
   my $config=Deploy::Core::init("$keys[$num]");
   my $FistSerInfo=Deploy::Core::prepare($keys[$num],$config->{'network_ip'},$config->{'pro_init'},$config->{'pro_key'},$config->{'pro_dir'},$config->{'config_dir'});
   Deploy::Core::downloading($keys[$num],$config->{'app_key'},$config->{'pro_dir'},$config->{'network_ip'},$config->{'config_dir'});	
   }
   Rex::Logger::info("下载远程服务器数据到本地完成---$keys[-1] 个.");
   }else{
   Rex::Logger::info("");
   Rex::Logger::info("开始下载远程服务器数据到本地.");
   for my $kv (@ks) {
   if ( $kv ne "" ){
   if (exists($vars{$kv})){
   Rex::Logger::info("");
   Rex::Logger::info("##############($kv)###############");
   my $config=Deploy::Core::init("$kv");
   my $FistSerInfo=Deploy::Core::prepare($kv,$config->{'network_ip'},$config->{'pro_init'},$config->{'pro_key'},$config->{'pro_dir'},$config->{'config_dir'});
   Deploy::Core::downloading($kv,$config->{'app_key'},$config->{'pro_dir'},$config->{'network_ip'},$config->{'config_dir'});	
   }else{
   Rex::Logger::info("关键字($kv)不存在","error");
   }
   }}
   Rex::Logger::info("");
   Rex::Logger::info("下载远程服务器数据到本地完成.");
   }
};

desc "检查数据库配置和远程服务器信息:rex check --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6' \n\t\t\t\t\t\t\t\t rex check --k='all'";
task "check",sub{
   my $self = shift;
   my $k=$self->{k};
   my $keys=Deploy::Db::getallkey();
   my @keys=split(/,/, $keys);
   my %vars = map { $_ => 1 } @keys; 
   my $lastnum=$keys[-1] - 1;
   if( $k eq ""  ){
   Rex::Logger::info("关键字(--k='')不能为空");
   exit;	
   }
   my @ks = split(/ /, $k);
   if ( $k eq "all" ){
   Rex::Logger::info("");
   Rex::Logger::info("开始检查 发布系统 服务器以及数据库配置---$keys[-1] 个.");
   for my $num (0..$lastnum) {
   Rex::Logger::info("");
   Rex::Logger::info("##############($keys[$num])###############");
   #初始化数据库信息
   my $config=Deploy::Core::init("$keys[$num]");
   #say $keys[$num];     
   #第一次连接获取远程服务器信息
   my $FistSerInfo=Deploy::Core::prepare($keys[$num],$config->{'network_ip'},$config->{'pro_init'},$config->{'pro_key'},$config->{'pro_dir'},$config->{'config_dir'});
   }
   Rex::Logger::info("检查 发布系统 服务器以及数据库配置完成---$keys[-1] 个.");
   }else{   
   Rex::Logger::info("");
   Rex::Logger::info("开始检查 发布系统 服务器以及数据库配置.");    
   for my $kv (@ks) {
   if ( $kv ne "" ){
   if (exists($vars{$kv})){	   
   Rex::Logger::info("");
   Rex::Logger::info("##############($kv)###############");
   #初始化数据库信息
   my $config=Deploy::Core::init("$kv");
   #第一次连接获取远程服务器信息
   my $FistSerInfo=Deploy::Core::prepare($kv,$config->{'network_ip'},$config->{'pro_init'},$config->{'pro_key'},$config->{'pro_dir'},$config->{'config_dir'});  
   }else{
   Rex::Logger::info("关键字($kv)不存在","error");
   }
   }}
   Rex::Logger::info("检查 发布系统 服务器以及数据库配置完成.");
   }
};

desc "所有发布系统命令模版:  rex run --k='atm jrdt cm3 carbiz3 cm6 carbiz6 rb3 rb6' --cmd='ls' \n\t\t\t\t\t\t\t rex run --k='all' --cmd='ls'";
task "run",sub{
   my $self = shift;
   my $cmd = $self->{cmd};
   my $k=$self->{k};
   if( $k eq ""  ){
   Rex::Logger::info("关键字(--k='')不能为空");
   exit;
   }
   if ( $cmd eq "" ){
   Rex::Logger::info("cmd命令不能为空.");
   exit;
   }
   my $keys=Deploy::Db::getallkey();
   my @keys=split(/,/, $keys);
   my %vars = map { $_ => 1 } @keys;
   my $lastnum=$keys[-1] - 1;
   my @ks = split(/ /, $k);
   if ( $k eq "all" ){
   Rex::Logger::info("");
   Rex::Logger::info("开始执行命令模板---$keys[-1] 个.");
   for my $num (0..$lastnum) {
   Rex::Logger::info("");
   Rex::Logger::info("##############($keys[$num])###############");
   my $config=Deploy::Core::init("$keys[$num]");
   run_task "Common:Use:run",on=>$config->{'network_ip'},params=>{ cmd=>"$cmd" }
   }
   Rex::Logger::info("执行命令模板完成---$keys[-1] 个.");
   }else{
   Rex::Logger::info("");
   Rex::Logger::info("开始执行命令模板.");
   for my $kv (@ks) {
   if ( $kv ne "" ){
   if (exists($vars{$kv})){
   Rex::Logger::info("");
   Rex::Logger::info("##############($kv)###############");
   my $config=Deploy::Core::init("$kv");
   run_task "Common:Use:run",on=>$config->{'network_ip'},params=>{ cmd=>"$cmd" }	
   }else{
   Rex::Logger::info("关键字($kv)不存在","error");
   }
   }}
   Rex::Logger::info("执行命令模板完成.");
   }
};

desc "获取APP_KEY list: rex list \n";
task "list",sub{
   my $keys=Deploy::Db::getallkey();
   Rex::Logger::info("");
   Rex::Logger::info("获取到APP_KEY list如下: \n $keys");
};
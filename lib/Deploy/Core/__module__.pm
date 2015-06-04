package Deploy::Core;

use Rex -base;
use Data::Dumper;
use Deploy::FirstConnect;
use Rex::Commands::DB {
                  dsn    => "DBI:mysql:database=autotask;host=localhost",
                  user    => "public",
                  password => "public",
                };
use Deploy::Db;
use Rex::Commands::Rsync;
use Rex::Commands::Sync;
use Deploy::other;
my @string=("id","app_key","server_name","network_ip","pro_type","config_dir","pro_dir","pro_key","pro_init","local_name","is_deloy_dir");
my $softdir="/data/RexDeploy/softdir/";
my $configuredir="/data/RexDeploy/configuredir/";
my $local_prodir="/data/RexDeploy/remotecomdir/softdir/";
my $local_confdir="/data/RexDeploy/remotecomdir/configuredir/";
my  $datetime = run "date '+%Y%m%d_%H%M%S'" ;

desc "加载数据库数据";
task init => sub {
   my  $k  = $_[0];
   Rex::Logger::info("开始从数据库初始化数据...");
   my $config = run_task "Deploy:Db:getconfig",params => { app_key => "$k"};
   if( $config == 0 ){
    Rex::Logger::info("($k)--系统应用关键字不能为空","error");
    #exit;
    return 0;
   }
   elsif( $config == 2 ){
    Rex::Logger::info("($k)--该关键字匹配到多个应用系统,请到数据库配置中确认配置是否OK.","error");
    return 2; 
    #exit
   }
   elsif( $config == 1 ){
    Rex::Logger::info("($k)--该关键字没有匹配到应用系统,请到数据库配置中确认配置是否OK.","error");
    return 1;
    #exit
   }
   Rex::Logger::info("($k)--获取到该服务器: id:$config->{'id'},app_key:$config->{'app_key'},其他信息请见数据库.");
   Rex::Logger::info("($k)--数据库初始化数据完成...");
   Rex::Logger::info("($k)--Get配置-1:id:$config->{'id'},app_key:$config->{'app_key'},pro_init:$config->{'pro_init'},pro_type:$config->{'pro_type'},network_ip:$config->{'network_ip'}");
   Rex::Logger::info("($k)--Get配置-2:pro_key:$config->{'pro_key'},pro_dir:$config->{'pro_dir'},config_dir:$config->{'config_dir'}");
   #判断关键字段是否为空
   for my $name (@string) {
   if( $config->{$name} eq "" ){
   Rex::Logger::info("($k)--关键字段:$name为空,请检查数据库配置.","warn");
   return ;
   #exit
   }
   }
   return $config;

};

desc "获远程服务器信息";
task prepare => sub {
   my  $k  = $_[0];
   my $network_ip = $_[1];
   my $pro_init = $_[2];
   my $pro_key = $_[3];
   my $pro_dir = $_[4];
   my $config_dir = $_[5];

   #获取远程服务器信息
   Rex::Logger::info("($k)--第一次连接,获取远程服务器基本信息.");
   my $FistSerInfo=run_task "Deploy:FirstConnect:getserinfo",on =>$network_ip,params => { pro_init => "$pro_init",pro_key => "$pro_key", pro_dir => "$pro_dir",config_dir => "$config_dir" };
   #启动文件判断
   if( $FistSerInfo->{'pro_init'}  == 0 ){
    Rex::Logger::info("($k)--系统启动文件不存在:$pro_init","error");
    #exit;
    return 0;
   }
   #工程目录和配置目录判断
   if( $FistSerInfo->{'pro_dir'}  == 0  ){
   Rex::Logger::info("($k)--系统工程目录不存在:$pro_dir","error");
   return 0;
   }
   if( $FistSerInfo->{'config_dir'}  == 0 ){
   Rex::Logger::info("($k)--系统配置目录不存在:$config_dir","error");
   return 0;
   }

   #进程判断
   if( $FistSerInfo->{'ps_num'}   == 0 ){
    Rex::Logger::info("($k)--系统应用进程不存在","warn");
   }
   else{
    Rex::Logger::info("($k)--系统进程存在:$FistSerInfo->{'ps_num'}.");
   }
   Rex::Logger::info("($k)--第一次连接,初始化服务器信息完成.");
   #say Dumper($FistSerInfo);  
   return $FistSerInfo;
};

desc "程序&配置传输 本地->远程";
task upload => sub {
    my $self = shift;
    my $dir1 = $self->{dir1};
    my $dir2 = $self->{dir2};
    my $dir3 = $self->{dir3};
    my $dir4 = $self->{dir4};
    my $is_deloy_dir = $self->{is_deloy_dir};
    my $k = $self->{k};
    $dir1 =~ s/\/$//;
    $dir2 =~ s/\/$//;
    $dir3 =~ s/\/$//;
    $dir4 =~ s/\/$//;
    $dir1 = $dir1."/";
    $dir3 = $dir3."/";
    if ( $is_deloy_dir == 1 ){
    Rex::Logger::info("($k)--开始传输程序目录." );
    Rex::Logger::info("syncing $dir1 => $dir2");
    sync $dir1,$dir2, {
#   sync_up $dir1,$dir2, {
    exclude => ["*.sw*", "*.tmp","*.log","*nohup.out","*.svn*"],
    parameters => '--backup --delete',
    };    
    Rex::Logger::info("($k)--传输程序目录完成.");   
    }elsif ($is_deloy_dir == 2) {
    Rex::Logger::info("($k)--开始传输程序和配置目录." );
    Rex::Logger::info("syncing $dir1 => $dir2 &  syncing $dir3 => $dir4");
    sync $dir1,$dir2, {
#   sync_up $dir1,$dir2, {
    exclude => ["*.sw*", "*.tmp","*.log","*nohup.out","*.svn*"],
    parameters => '--backup --delete',
    };
    
    sync $dir3,$dir4, {
#   sync_up $dir3,$dir4, {
    exclude => ["*.sw*", "*.tmp","*.log","*nohup.out","*.svn*"],
    parameters => '--backup --delete',
    };
    Rex::Logger::info("($k)--传输程序和配置目录完成.");
    }else{
    Rex::Logger::info("上传目录的数量不正确,一般上传目录分为:程序目录和配置目录或者程序目录.","error");
    };    
};

desc "程序&配置传输 远程->本地";
task download => sub {
    my $self = shift;
    my $dir1 = $self->{dir1};
    my $dir2 = $self->{dir2};
    my $dir3 = $self->{dir3};
    my $dir4 = $self->{dir4};
    my $k = $self->{k};
    $dir1 =~ s/\/$//;
    $dir2 =~ s/\/$//;
    $dir3 =~ s/\/$//;
    $dir4 =~ s/\/$//;
    $dir1 = $dir1."/";
    $dir3 = $dir3."/";    
    if ( ! is_dir( "$dir1" ) ){
    Rex::Logger::info("($k)--远程程序目录:$dir1不存在","error");
    exit;
    }
    if ( ! is_dir( "$dir3" ) ){
    Rex::Logger::info("($k)--本地配置目录:$dir3 不存在","error");
    exit;
    };
    Rex::Logger::info("($k)--syncing $dir1 => $dir2");
    sync $dir1,$dir2, {
    download => 1,
    exclude => ["*.sw*", "*.tmp","*.log","*nohup.out","*.svn*"],
    parameters => '--backup',
    };
    Rex::Logger::info("($k)--syncing $dir3 => $dir4");
    sync $dir3,$dir4, {
    download => 1,
    exclude => ["*.sw*", "*.tmp","*.log","*nohup.out","*.svn*"],
    parameters => '--backup',
    };

};

desc "程序&配置发布-> 本地->远程";
task uploading => sub {
   my  $k  = $_[0];
   my  $local_name = $_[1];
   my  $remotedir = $_[2];
   my  $network_ip = $_[3];
   my  $app_key = $_[5];
   my  $is_deloy_dir = $_[6];
   my  $pro_dir = $_[7];
   my  $config_dir = $_[8];
   my  $remote_confir_dir = $_[4];
   #my  $datetime = run "date '+%Y%m%d_%H%M%S'" ;
   $remotedir =~ s/\/$//;
   $remotedir = "${remotedir}_${datetime}";
   my $localdir = "$softdir$local_name/";
   $remote_confir_dir =~ s/\/$//;
   $remote_confir_dir ="${remote_confir_dir}_${datetime}";
   my $local_config_dir = "$configuredir$app_key/";
   LOCAL {
   if ( ! is_dir( "$localdir" ) ){
   Rex::Logger::info("($k)--本地程序目录:$localdir 不存在","error");
   exit;
   }
   if ( ! is_dir( "$local_config_dir" ) ){
   Rex::Logger::info("($k)--本地配置目录:$local_config_dir 不存在","error");
   exit;
   }
   };
   #根据is_deloy_dir的值,判断是否需要再次将本地配置文件,再次合并到本地工程目录里面。
   LOCAL {
   my  $current_server = connection->server;
   if($is_deloy_dir == 1 ){
   $pro_dir =~ s/\///g;
   $config_dir =~ s/\///g;
   $config_dir =~ s/$pro_dir//g;
   $localdir=~ s/\/$//;
   $local_config_dir=~ s/\/$//;
   Rex::Logger::info("($k)--合并配置文件到工程[$current_server]: rsync -ar --delete $local_config_dir/  $localdir/$config_dir ");
   run "rsync -ar --delete $local_config_dir/  $localdir/$config_dir"; 
   }
   };
#   Rex::Logger::info("($k)--开始传输程序和配置目录." );
   run_task "Deploy:Core:upload",on=>"$network_ip",params => {dir1=>"$localdir",dir2=>"$remotedir",dir3=>"$local_config_dir",dir4=>"$remote_confir_dir",is_deloy_dir=>"$is_deloy_dir",k=>"$k"};
#   Rex::Logger::info("($k)--传输程序和配置目录完成.");
   my $dir;
   $dir->{'remote_prodir'}=$remotedir;
   if($is_deloy_dir == 1){
   $dir->{'remote_configdir'}="null";
   }else{
   $dir->{'remote_configdir'}=$remote_confir_dir;
   }
   $dir->{'localdir'}=$localdir;
   $dir->{'local_config_dir'}=$local_config_dir;
   return $dir;
};

desc "程序&配置下载-> 远程->本地";
task downloading => sub {
   our  $k  = $_[0];
   my  $local_name = $_[1];
   my  $remotedir = $_[2];
   my  $network_ip = $_[3];
   my  $remote_confir_dir = $_[4];
   my  $datetime = run "date '+%Y%m%d_%H%M%S'" ;
   if(  $remotedir =~m/\/$/ ) { 
   $remotedir = "${remotedir}";
   }else{
   $remotedir = "${remotedir}/";
   }
   my $localdir = "$local_prodir$local_name/";
   if(  $remote_confir_dir =~m/\/$/) {
   $remote_confir_dir ="${remote_confir_dir}";
   }else{
   $remote_confir_dir ="${remote_confir_dir}/";
   }
   my $local_config_dir = "$local_confdir$local_name/";
   #say $remotedir . " || $localdir". " || $remote_confir_dir" . " || $local_config_dir"  ;
   #exit
   if( ! is_dir($localdir) ){
   run "mkdir -p $localdir"
   }
   if ( ! is_dir($local_config_dir)){
   run "mkdir -p $local_config_dir"; 
   }
#   if ( is_file('~/.ssh/known_hosts')){
#   run "rm -f ~/.ssh/known_hosts";	
#   }
   Rex::Logger::info("($k)--开始传输程序和配置目录到本地." );
   run_task "Deploy:Core:download",on=>"$network_ip",params => {dir2=>"$localdir",dir1=>"$remotedir",dir4=>"$local_config_dir",dir3=>"$remote_confir_dir",k=>"$k"};
   Rex::Logger::info("($k)--传输程序和配置目录到本地完成:$localdir || $local_config_dir");
};

desc "更改软链接,重启应用";
task linkrestart=>sub{
   my $self = shift;
   my  $k  = $self->{k};
   my  $network_ip = $self->{network_ip};
   my  $ps_num = $self->{ps_num};
   my  $pro_key = $self->{pro_key};
   my  $pro_init = $self->{pro_init};
   my  $remote_prodir= $self->{remote_prodir};
   my  $remote_configdir = $self->{remote_configdir};
   my  $pro_dir = $self->{pro_dir};
   my  $config_dir = $self->{config_dir};
   my  $is_deloy_dir = $self->{is_deloy_dir};
   my  $localdir = $self->{localdir};
   my  $local_config_dir = $self->{local_config_dir};
   #去掉软链接最后的/
   $pro_dir =~ s/\/$//;
   $config_dir =~ s/\/$//;
   $local_config_dir =~ s/\/$//;
   #特殊应用处理
   run_task "Deploy:other:expother",on=>"$network_ip",params => { k => "$k",remote_prodir=>"$remote_prodir",remote_configdir=>"$remote_configdir",pro_dir=>"$pro_dir",config_dir=>"$config_dir",localdir=>"$localdir",local_config_dir=>"$local_config_dir"};
   #获取更换软链接的状态,目前只支持1个和2个目录的同步
   if($is_deloy_dir == 1 ){
   my $pro_desc_be=run "ls $pro_dir -ld |grep -v sudo |grep '^l'|awk '{print \$(NF-2),\$(NF-1),\$NF}'" ;
   Rex::Logger::info("($k)--发布前软链接详情: $pro_desc_be --> only");
   }else{
   my $pro_desc_be=run "ls $pro_dir -ld |grep -v sudo |grep '^l'|awk '{print \$(NF-2),\$(NF-1),\$NF}'" ;
   my $conf_desc_be=run "ls $config_dir -ld |grep -v sudo |grep '^l' |awk '{print \$(NF-2),\$(NF-1),\$NF}'";
   Rex::Logger::info("($k)--发布前软链接详情: $pro_desc_be || $conf_desc_be");
   }
   #重启,更改软链接
   if ($ps_num == 0){
   
   link_start($k, $pro_dir,$config_dir,$remote_configdir,$remote_prodir,$pro_key,$pro_init,$is_deloy_dir);   

   }#ps_num结束
   else{
   Rex::Logger::info("($k)--进程数为$ps_num,开始关闭应用->更改程序配置软链接->启动.");
   run "/bin/bash $pro_init stop;sleep 2";   
   my $ps_stop_num = run "ps aux |grep -v grep |grep -v sudo |grep '$pro_key' |wc -l";
   if( $ps_stop_num == 0  ){
   Rex::Logger::info("($k)--进程数为$ps_stop_num,关闭成功.");

   link_start($k, $pro_dir,$config_dir,$remote_configdir,$remote_prodir,$pro_key,$pro_init,$is_deloy_dir);   

   }else{
   Rex::Logger::info("($k)--进程数为$ps_stop_num,关闭失败->kill应用.","warn");
   my @apps = grep { $_->{"command"} =~ m/$pro_key/ } ps();

   for my $app (@apps) {
   run  "kill -9  $app->{'pid'}";
   }
   my $ps_stop_num2 = run "ps aux |grep -v grep |grep -v sudo |grep '$pro_key' |wc -l";
   if( $ps_stop_num2 == 0  ){Rex::Logger::info("($k)--kill应用-成功.");}else{Rex::Logger::info("($k)--kill应用-失败->略过此系统的发布.","error");return 0;}
    
   #更改软链接->重启-start  
   link_start($k, $pro_dir,$config_dir,$remote_configdir,$remote_prodir,$pro_key,$pro_init,$is_deloy_dir);
   #更改软链接->重启-end  
   }
 
   }#ps_num else结束
   #更改软链接->重启-start,更改前程序已经处于停止的状态.
   sub link_start  {
   my ($k, $pro_dir,$config_dir,$remote_configdir,$remote_prodir,$pro_key,$pro_init,$is_deloy_dir) = @_;
   if($is_deloy_dir == 1){
   Rex::Logger::info("($k)--进程数为0,开始更改程序软链接.");
   my $link_status=run "ls $pro_dir -ld |grep '^l' |wc -l" ;
   if ($link_status == 0) {
   run "mv $pro_dir ${pro_dir}_$datetime";
   Rex::Logger::info("($k)--程序目录不为软链接: mv $pro_dir ${pro_dir}_$datetime");
   }else{
   run "unlink $pro_dir;ln -s $remote_prodir $pro_dir";
   run "chown www.www   $remote_prodir $pro_dir -R" ;
   }
   my $pro_desc=run "ls $pro_dir -ld |grep '^l'|awk '{print \$(NF-2),\$(NF-1),\$NF}'" ;
   Rex::Logger::info("($k)--进程数为0,发布后软链接详情: $pro_desc ");
   Rex::Logger::info("($k)--进程数为0,更改程序&更改权限完成.");
   if ( !is_dir($pro_dir) ){
   Rex::Logger::info("($k)--进程数为0,修改软链接失败:$pro_dir.",'error');		
   }		       
   }elsif($is_deloy_dir == 2){#else开始
   my $link_status=run "ls $pro_dir -ld |grep '^l' |wc -l" ;
   if ($link_status == 0) {
   run "mv $pro_dir ${pro_dir}_$datetime";
   Rex::Logger::info("($k)--程序目录不为软链接: mv $pro_dir ${pro_dir}_$datetime");
   }else{
   run "unlink $pro_dir;ln -s $remote_prodir $pro_dir"
   }
   my $linkc_status=run "ls $config_dir -ld |grep '^l' |wc -l" ;
   if ($linkc_status == 0) {
   run "mv $config_dir ${pro_dir}_$datetime";
   Rex::Logger::info("($k)--配置目录不为软链接: mv $config_dir  ${pro_dir}_$datetime");
   }else{
   run "unlink $config_dir;ln -s $remote_configdir $config_dir";
   run "chown www.www $remote_configdir $config_dir $remote_prodir $pro_dir -R ;";
   }
   my $pro_desc=run "ls $pro_dir -ld |grep '^l'|awk '{print \$(NF-2),\$(NF-1),\$NF}'" ;
   my $conf_desc=run "ls $config_dir -ld |grep '^l' |awk '{print \$(NF-2),\$(NF-1),\$NF}'";
   Rex::Logger::info("($k)--进程数为0,发布后软链接详情: $pro_desc || $conf_desc");
   Rex::Logger::info("($k)--进程数为0,更改程序&配置软链接&更改权限完成.");
   if ( !is_dir($pro_dir) ){
   Rex::Logger::info("($k)--进程数为0,修改软链接失败:$pro_dir.",'error');       
   }
   if ( !is_dir($config_dir) ){
   Rex::Logger::info("($k)--进程数为0,修改软链接失败:$config_dir.",'error');       
   }	   
   }#else结束   
   Rex::Logger::info("($k)--进程数为0,开始启动应用.");
   my $servername=$pro_init;
   $servername=~s /\/etc\/init.d\///g;
   service $servername => "start";  
 
   #run "source /etc/profile ;/bin/bash $pro_init start";
   my $ps_start_num = run "ps aux |grep -v grep |grep -v sudo |grep '$pro_key' |wc -l";
   if( $ps_start_num == 0  ){
   Rex::Logger::info("($k)--进程数为0,启动失败.($pro_init start)","error");
   }else{
   Rex::Logger::info("($k)--进程数为$ps_start_num,启动成功.");
   }
 
   } 


};

#desc "服务的启动和关闭";
#task "service", sub {
#   service "jrdt",
#     ensure  => "started",
#     start   => "/usr/local/tomcat/bin/startup.sh",
#     stop    => "/usr/local/tomcat/bin/shutdown.sh",
#     status  => "ps -efww | grep tomcat",
#};
#
desc "同步本地(远程download)的程序和配置=>待发布目录";
task "syncpro",sub {

my $localnames=run_task "Deploy:Db:getlocalname";

Rex::Logger::info("开始操作基础分区目录.");
#mv 基础分区的程序和配置的到发布目录
my @base = split(/,/, $localnames->{'base'});
for my $item (@base) {
my $deploy_prodir="$softdir$item";
my $deploy_confdir="$configuredir$item";
my $down_prodir="$local_prodir$item";
my $down_confdir="$local_confdir$item";
#删除发布目录
if( is_dir($deploy_prodir) ){
rmdir($deploy_prodir);
Rex::Logger::info("删除发布程序目录完成: rmdir $deploy_prodir.");
}

if( is_dir($deploy_confdir) ){
rmdir($deploy_confdir);
Rex::Logger::info("删除发布配置目录完成: rmdir $deploy_confdir.");
}

if( is_dir($down_prodir) ){
mv($down_prodir,$softdir);
Rex::Logger::info("mv程序目录完成: mv($down_prodir,$softdir).");
}else{
Rex::Logger::info("待上传程序目录不存在:  $down_prodir.","warn");
}

if( is_dir($down_confdir) ){
mv($down_confdir,$configuredir);
Rex::Logger::info("mv配置目录完成: mv($down_confdir,$configuredir).");
}else{
Rex::Logger::info("待上传配置目录不存在:  $down_confdir.","warn");
}

}
Rex::Logger::info("操作基础分区目录完成.");


Rex::Logger::info("开始操作分区三目录.");
my @bases3local_name = split(/,/, $localnames->{'bases3local_name'});
my @bases3app_key = split(/,/, $localnames->{'bases3app_key'});
my $len=@bases3local_name;
my $lastnum=$len - 1;
for my $num (0..$lastnum) {
my $item3=$bases3local_name[$num];
my $item33=$bases3app_key[$num];
my $deploy_prodir="$softdir$item3";
my $deploy_confdir="$configuredir$item33";
my $down_prodir="$local_prodir$item33";
my $down_confdir="$local_confdir$item33";
#say "mv($down_confdir,$deploy_confdir)";
#say "mv($down_prodir,$deploy_prodir)";
#删除发布目录
if( is_dir($deploy_confdir) ){
rmdir($deploy_confdir);
Rex::Logger::info("删除发布配置目录完成: rmdir $deploy_confdir.");
}
if( is_dir($deploy_prodir) ){
rmdir($deploy_prodir);
Rex::Logger::info("删除发布程序目录完成: rmdir $deploy_prodir.");
}

if( is_dir($down_confdir) ){
mv($down_confdir,$deploy_confdir);
Rex::Logger::info("mv配置目录完成: mv($down_confdir,$deploy_confdir).");
}else{
Rex::Logger::info("待上传配置目录不存在:  $down_confdir.","warn");
}

if( is_dir($down_prodir) ){
mv($down_prodir,$deploy_prodir);
Rex::Logger::info("mv程序目录完成: mv($down_prodir,$deploy_prodir).");
}else{
Rex::Logger::info("待上传程序目录不存在:  $down_prodir.","warn");
}

}

Rex::Logger::info("操作分区三目录完成.");

};
1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Deploy::Core/;

 task yourtask => sub {
    Deploy::Core::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
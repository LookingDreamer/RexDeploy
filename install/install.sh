#!/bin/bash
logdir=/data/log/shell          #日志路径
log=$logdir/shell.log            #日志文件 
is_font=1                #终端是否打印日志: 1打印 0不打印 
is_log=0                 #是否记录日志: 1记录 0不记录
tarlist="
DBD-mysql-4.031.tar.gz
DBI-1.633.tar.gz
"

datef(){
date "+%Y-%m-%d %H:%M:%S"
}
  
print_log(){
if [[ $is_log -eq 1  ]];then
[[ -d $logdir ]] || mkdir -p $logdir
echo "[ $(datef) ] $1" >> $log
fi
if [[ $is_font -eq 1  ]];then
echo -e "[ $(datef) ] $1"
fi
}

untar(){
for i in $tarlist
do
name=$(echo $i |sed "s/.tar.gz//")
if [[ ! -d $name  ]];then
print_log "开始解压---$name"
tar -zxf $i
print_log "解压完成---$name"
else
print_log "解压后文件夹已存在---$name"
fi
done
}

install(){

if [[ -f /usr/bin/rex  ]];then
print_log "rex框架已经安装."
else
print_log "开始安装rex框架..."
cat >/etc/yum.repos.d/rex.repo <<EOF
[rex]
name=Fedora \$releasever - \$basearch - Rex Repository
baseurl=http://rex.linux-files.org/CentOS/\$releasever/rex/\$basearch/
enabled=1
EOF

yum install rex --nogpgcheck -y

print_log "安装rex框架完成."
fi

print_log "开始安装perl支持"
moule_list=$(find `perl -e 'print "@INC"'` -name '*.pm' -print)
dbi_list=$(echo -e "$moule_list" |grep "^/usr" |grep "DBI.pm" |wc -l)
dbd_list=$(echo -e "$moule_list" |grep "^/usr" |grep DBD |grep mysql |wc -l)
if [[ $dbi_list -eq 0  ]];then
#DBI安装
print_log "DBI模块开始安装."
cd DBI-1.633
perl Makefile.PL 
make
make install
print_log "DBI模块安装完成."
else
print_log "DBI模块已经安装."
fi
if [[ $dbd_list -eq 0  ]];then
print_log "DBD-mysql模块开始安装."
#DBD安装
yum install zlib-devel  -y
cd DBD-mysql-4.031
perl Makefile.PL
make
make install
print_log "DBD-mysql模块安装完成."
else
print_log "DBD-mysql模块已经安装."
fi
#expect安装
#yum install expect* -y
print_log "安装perl支持完成"
}

untar
install

if [[ ! -d  /data/RexDeploy ]];then
mkdir /data/RexDeploy -p
cp ../*   /data/RexDeploy  -ar
else
print_log "已经存在安装目录:/data/RexDeploy"
fi 
cd /data/RexDeploy
print_log "安装完成 --安装目录:/data/RexDeploy"

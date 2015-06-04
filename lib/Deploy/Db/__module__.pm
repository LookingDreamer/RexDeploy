package Deploy::Db;

use Rex -base;
use Data::Dumper;
use Rex::Commands::DB {
                  dsn    => "DBI:mysql:database=autotask;host=localhost",
                  user    => "public",
                  password => "public",
                };
my $table="pre_host_zzb";

desc "数据库模块: 获取服务器信息";
task getconfig => sub {
   my $self = shift;
   my $app_key = $self->{app_key};
   if( $app_key eq "" ) {
   return 0;
   }
   my @data = db select => {
            fields => "*",
            from  => $table,
            where  => "app_key='$app_key'",
          };
   my %config=();
   my $config ;
   shift my @ids;
   for my $list (@data) {
   push(@ids,$list->{'id'});
   $config{id}=$list->{'id'};
   $config{app_key}=$list->{'app_key'};
   $config{depart_name}=$list->{'depart_name'};
   $config{server_name}=$list->{'server_name'};
   $config{network_ip}=$list->{'network_ip'};
   $config{cpu}=$list->{'cpu'};
   $config{mem}=$list->{'mem'};
   $config{disk}=$list->{'disk'};
   $config{pro_type}=$list->{'pro_type'};
   $config{config_dir}=$list->{'config_dir'};
   $config{pro_dir}=$list->{'pro_dir'};
   $config{log_dir}=$list->{'log_dir'};
   $config{pro_key}=$list->{'pro_key'};
   $config{pro_init}=$list->{'pro_init'};
   $config{pro_port}=$list->{'pro_port'};
   $config{system_type}=$list->{'system_type'};
   $config{created_time}=$list->{'created_time'};
   $config{updated_time}=$list->{'updated_time'};
   $config{status}=$list->{'status'};
   $config{note}=$list->{'note'};
   $config{mask}=$list->{'mask'};
   $config{local_name}=$list->{'local_name'};
   $config{is_deloy_dir}=$list->{'is_deloy_dir'};

   $config{config_dir}=~ s/ //g;
   $config{pro_dir}=~ s/ //g;
   #$config{log_dir}=~ s/ //g;
   $config{pro_init}=~ s/ //g;   
   }
   my $len=@ids;
   if($len == 0 ){
   return 1;
   }
   if($len != 1){
   return 2;		
#  Rex::Logger::info("( $app_key )--该关键字匹配到多个应用系统,请到数据库配置中确认配置是否OK.");
   exit
   }
   return \%config;
#  Rex::Logger::info("从数据库初始化数据完成...");
};

desc "获取所有应用系统的APP_KEY";
task getallkey=>sub {
my @data = db select => {
            fields => "app_key",
            from  => $table,
            where  => "app_key != '' and app_key is not null ",
          };
   shift my @keys;
   for my $list (@data) {
   push(@keys,$list->{'app_key'});
   }
   my $len=@keys;
   if($len == 0 ){
   Rex::Logger::info("没有找到任何的应用系统关键字.");
   exit;
   }
   push(@keys,$len);
   my $keys = join(",", @keys);
   return $keys;
};

desc "根据关键词获取分组";
task "getgroup" => sub {
   my @data = db select => {
            fields => "network_ip",
            from  => $table,
            where  => "network_ip != '' and network_ip is not null order by network_ip",
          };
   shift my @ips;
   for my $list (@data) {
   push(@ips,$list->{'network_ip'});
   }
   my $ips = join(",", @ips);
   return $ips;    
};

desc "获取local_name列表";
task "getlocalname"=>sub {
   my @data = db select => {
            fields => "local_name",
            from  => $table,
            where  => "groupby ='base' and app_key !='' and app_key is not null and app_key=local_name",
          };
   shift my @bases;
   for my $list (@data) {
   push(@bases,$list->{'local_name'});
   }
   my $bases = join(",", @bases);

   my @data3 = db select => {
            fields => "app_key,local_name",
            from  => $table,
            where  => "groupby='depart3' and app_key!=local_name and  app_key!='' and local_name!='' and local_name is not null and app_key is not null",
          };
   shift my @bases3app_key;
   shift my @bases3local_name;

   for my $list (@data3) {
   push(@bases3app_key,$list->{'app_key'});
   push(@bases3local_name,$list->{'local_name'});
   }
   my $bases3app_key = join(",", @bases3app_key);
   my $bases3local_name = join(",", @bases3local_name);

#   my @data6 = db select => {
#            fields => "local_name",
#            from  => $table,
#            where  => "groupby='depart6' and app_key!=local_name and  app_key !='' and app_key is not null",
#          };
#   shift my @bases6;
#   for my $list (@data6) {
#   push(@bases6,$list->{'local_name'});
#   }
#   my $bases6 = join(",", @bases6);

   my %localnames=();
   my $localnames;
   $localnames{base}=$bases; 
   $localnames{bases3app_key}=$bases3app_key;
   $localnames{bases3local_name}=$bases3local_name;
   return \%localnames;
  

};
1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Deploy::Db/;

 task yourtask => sub {
    Deploy::Db::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
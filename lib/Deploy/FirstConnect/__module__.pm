package Deploy::FirstConnect;

use Rex -base;
desc "获取远程服务器信息";
task getserinfo => sub {
    my $self = shift;
    my $pro_key = $self->{pro_key};
    my $pro_init = $self->{pro_init};
    my $pro_dir = $self->{pro_dir};
    my $config_dir = $self->{config_dir};
    my %myserinfo=();
    my $myserinfo ;
#   my $init_file= run_task "Deploy:Ps:isfile",params => { file => "$pro_init"};
    #进程 
    my $ps_num = run "ps aux |grep -v grep |grep -v sudo | grep '$pro_key' |wc -l" ; 
#   my $init_file = run "if [[ -f $pro_init ]];then echo 'exist-01';else echo 'no-01' ; fi";	
    $myserinfo{ps_num}=$ps_num;
    #启动文件
    if( is_file("$pro_init") ) {
    $myserinfo{pro_init}=1;
     }
     else {
    $myserinfo{pro_init}=0;
    }
    #应用程序和配置目录
    if( is_dir("$pro_dir") ){
    $myserinfo{pro_dir}=1;
    }else{
    $myserinfo{pro_dir}=0;
    }
    if( is_dir("$config_dir") ){
    $myserinfo{config_dir}=1;
    }else{
    $myserinfo{config_dir}=0;
    }
    

    return \%myserinfo;
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Deploy::FirstConnect/;

 task yourtask => sub {
    Deploy::FirstConnect::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut

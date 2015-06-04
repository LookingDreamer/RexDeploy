package Common::Use;

use Rex -base;
use Rex::Commands::Rsync;

desc "通用命令模版";
task run =>, group => "myserver",sub {

my $self = shift;
my $cmd = $self->{cmd};

run $cmd, sub {
     my ($stdout, $stderr) = @_;
     my $server = Rex::get_current_connection()->{server};
     say "[$server] $stdout";
     say "" ;
    };
};

desc "通用文件传输 远程->本地";
task "download",group => "myserver", sub {
   my $self = shift;
   my $dir1 = $self->{dir1};
   my $dir2 = $self->{dir2};

   sync $dir1,$dir2, {
   download => 1,
   parameters => '--backup',
   };
 };

desc "通用文件传输 本地->远程";
task "upload",group => "myserver", sub {
    my $self = shift;
    my $dir1 = $self->{dir1};
    my $dir2 = $self->{dir2};

    sync $dir1,$dir2, {
    exclude => ["*.sw*", "*.tmp"],
    parameters => '--backup --delete',
   };
 };


=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Common::Use/;

 task yourtask => sub {
    Common::Use::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut

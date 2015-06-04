package Deploy::other;

use Rex -base;

desc "特殊应用发布更改";
task expother => sub {
   my $self = shift;
   my  $k  = $self->{k};
   my  $remote_prodir= $self->{remote_prodir};
   my  $remote_configdir = $self->{remote_configdir};
   my  $pro_dir = $self->{pro_dir};
   my  $config_dir = $self->{config_dir};
   my  $localdir = $self->{localdir};
   my  $local_config_dir = $self->{local_config_dir};
   my $current_server = connection->server;
   if ( $k eq "jrdt-houtai" ){
   Rex::Logger::info("($k)--特殊应用处理--");
   run "\cp $pro_dir/WEB-INF/classes/jdbc.dicon $remote_prodir/WEB-INF/classes/jdbc.dicon";
   Rex::Logger::info("($k)--特殊应用处理完成--");
   }elsif ($k eq "atm"){
   Rex::Logger::info("($k)--特殊应用处理--");
   Rex::Logger::info("($k: $current_server ): cp $pro_dir/WEB-INF/web.xml  $remote_prodir/WEB-INF/web.xml");
   run  "rm $remote_prodir/WEB-INF/web.xml -f ; cp $pro_dir/WEB-INF/web.xml  $remote_prodir/WEB-INF/web.xml";
   Rex::Logger::info("($k)--特殊应用处理完成--");
   }

};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Deploy::other/;

 task yourtask => sub {
    Deploy::other::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut

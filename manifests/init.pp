# @summary Reports logs and metrics to logstash via tcp
#
# @author
#   Mike Fröhner <m.froehner@syseleven.de> www.syseleven.de
#
# @see https://www.github.com/syseleven/puppet-logstash-tcp-reporter
#
# @param logstash_host
#   Hostname or IP of the logstash server
# @param logstash_port
#   Port of the logstash server
# @param logstash_timeout
#   Timeout in seconds to connect to the logstash server
# @param config_owner
#   Owner of the configuration file
# @param config_group
#   Group of the configuration file
#
# @example add the class to your puppetserver profile
#   class { 'logstash_tcp_reporter':
#     logstash_host => 'logstash.example.com',
#     logstash_port => 5999,
#   }
#
#   # Then add the String 'logstash_tcp' to 'reports' setting in the main section of your Puppetserver
#
class logstash_tcp_reporter (
  Stdlib::Host         $logstash_host    = '127.0.0.1',
  Stdlib::Port         $logstash_port    = 5999,
  Integer              $logstash_timeout = 10,
  String               $config_owner     = $logstash_tcp_reporter::params::config_owner,
  String               $config_group     = $logstash_tcp_reporter::params::config_group,
) inherits logstash_tcp_reporter::params {
  file { '/etc/puppetlabs/puppet/logstash_tcp.yaml':
    ensure  => file,
    content => template("${module_name}/logstash_tcp.yaml.erb"),
    mode    => '0440',
    owner   => $config_owner,
    group   => $config_group,
  }
}

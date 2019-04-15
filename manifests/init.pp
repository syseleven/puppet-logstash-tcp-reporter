# @summary Reports logs and metrics to logstash via tcp
#
# @author
#   Mike Fröhner <m.froehner@syseleven.de> www.syseleven.de
#
# @see https://www.github.com/syseleven/puppet-logstash-tcp-reporter
#
# @param host
#   Hostname or IP of the logstash server
# @param port
#   Port of the logstash server
# @param timeout
#   Timeout in seconds to connect to the logstash server
# @param ssl_enable
#   Enable SSL/TLS support
# @param ssl_cert
#   Client certificate path
# @param ssl_key
#   Client certificate path
# @param ssl_version
#   SSL version for connection to logstash server
# @param ssl_ca_path
#   directory path of CA certificates
# @param ssl_ca_file
#   file path of a CA certificate
# @param config_owner
#   Owner of the configuration file
# @param config_group
#   Group of the configuration file
#
# @example 1 - configure puppet send data to logstash without ssl
#   class { 'logstash_tcp_reporter':
#     host => 'logstash.example.com',
#     port => 5999,
#   }
#
# @example 1 - configure your logstash tcp input without ssl
#   input {
#     tcp {
#       codec => json
#       host => <host> (Optional)
#       port => 5999
#       type => "puppet"
#     }
#   }
#
# @example 2 - send data to logstash with ssl
#   class { 'logstash_tcp_reporter':
#     host       => 'logstash.example.com',
#     port       => 5999,
#     ssl_enable => true,
#   }
#
# @example 2 - configure your logstash tcp input with ssl
#   input {
#     tcp {
#       codec => json
#       host => <host> (Optional)
#       port => 5999
#       type => "puppet"
#       ssl_enable => true
#       ssl_cert => <path to ssl cert>
#       ssl_key => <path to ssl key>
#       ssl_extra_chain_certs => [ <path to ssl chain> ]
#       ssl_verify => false (this is very important if you don't use client certificates)
#     }
#   }
#
class logstash_tcp_reporter (
  Stdlib::Host                   $host         = '127.0.0.1',
  Stdlib::Port                   $port         = 5999,
  Integer                        $timeout      = 10,
  Boolean                        $ssl_enable   = false,
  Optional[Stdlib::Absolutepath] $ssl_cert     = undef,
  Optional[Stdlib::Absolutepath] $ssl_key      = undef,
  String                         $ssl_version  = ':TLSv1_2',
  Stdlib::Absolutepath           $ssl_ca_path  = '/etc/ssl/certs',
  Optional[Stdlib::Absolutepath] $ssl_ca_file  = '/etc/ssl/certs/ca-certificates.crt',
  String                         $config_owner = $logstash_tcp_reporter::params::config_owner,
  String                         $config_group = $logstash_tcp_reporter::params::config_group,
) inherits logstash_tcp_reporter::params {
  if $ssl_enable {
    if $ssl_cert != undef and $ssl_key == undef {
      fail('You cannot set only parameter ssl_cert, you have set also parameter ssl_key!')
    }

    if $ssl_key != undef and $ssl_cert == undef {
      fail('You cannot set only parameter ssl_key, you have set also parameter ssl_cert!')
    }
  }

  file { '/etc/puppetlabs/puppet/logstash_tcp.yaml':
    ensure  => file,
    content => template("${module_name}/logstash_tcp.yaml.erb"),
    mode    => '0440',
    owner   => $config_owner,
    group   => $config_group,
  }
}

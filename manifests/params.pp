# @summary Default values
#
#
class logstash_tcp_reporter::params {
  if $::is_pe {
    $config_owner = 'pe-puppet'
    $config_group = 'pe-puppet'
  } else {
    $config_owner = 'puppet'
    $config_group = 'puppet'
  }
}

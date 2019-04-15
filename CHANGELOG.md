# 0.9.5 (Apr 16th 2019) SSL/TLS support
## features
- added SSL/TLS support over TCP
- added client certificate/key

## breaking changes
- adjusted parameter names without deprecating old parameter

## upcoming
- add switch to disable 'OpenSSL::SSL::VERIFY_PEER'

# 0.9.0 (Apr 10th 2019) first official release
## summary
- added basic logstash tcp reporter
- added rspec tests
- added beaker-rspec tests

## features
- writing a config file to puppet config directory
- sends metrics and logs to logstash over tcp input

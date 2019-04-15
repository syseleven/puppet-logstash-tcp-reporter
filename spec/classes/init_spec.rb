# frozen_string_literal: true

require 'spec_helper'

describe 'logstash_tcp_reporter' do
  on_supported_os.each do |os, os_facts|
    let(:facts) do
      os_facts.merge(
        is_pe: false,
      )
    end

    context "on #{os}" do
      context 'with default parameters' do
        it {
          expect(subject).to compile.with_all_deps
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 127.0.0.1\n:port: 5999\n:timeout: 10\n:ssl_enable: Off\n",
            'mode' => '0440',
            'owner' => 'puppet',
            'group' => 'puppet',
          )
        }
      end

      context 'with other server parameters' do
        let(:params) do
          {
            host: '8.8.8.8',
            port: 1337,
            timeout: 24,
            config_owner: 'somebody_else',
            config_group: 'somebody_else',
          }
        end

        it {
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 8.8.8.8\n:port: 1337\n:timeout: 24\n:ssl_enable: Off\n",
            'mode' => '0440',
            'owner' => 'somebody_else',
            'group' => 'somebody_else',
          )
        }
      end

      context 'with ssl true' do
        let(:params) do
          {
            ssl_enable: true,
          }
        end

        it {
          expect(subject).to compile.with_all_deps
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 127.0.0.1\n:port: 5999\n:timeout: 10\n:ssl_enable: On\n:ssl_version: :TLSv1_2\n:ssl_ca_path: /etc/ssl/certs\n:ssl_ca_file: /etc/ssl/certs/ca-certificates.crt\n:ssl_cert: None\n:ssl_key: None\n",
            'mode' => '0440',
            'owner' => 'puppet',
            'group' => 'puppet',
          )
        }
      end

      context 'with ssl true and client cert/key' do
        let(:params) do
          {
            ssl_enable: true,
            ssl_cert: '/some/ssl/certificate.crt',
            ssl_key: '/some/ssl/key.key',
          }
        end

        it {
          expect(subject).to compile.with_all_deps
          expect(subject).to contain_class('logstash_tcp_reporter')
          expect(subject).to contain_class('logstash_tcp_reporter::params')

          expect(subject).to contain_file('/etc/puppetlabs/puppet/logstash_tcp.yaml').with(
            'ensure' => 'file',
            'content' => "---\n:host: 127.0.0.1\n:port: 5999\n:timeout: 10\n:ssl_enable: On\n:ssl_version: :TLSv1_2\n:ssl_ca_path: /etc/ssl/certs\n:ssl_ca_file: /etc/ssl/certs/ca-certificates.crt\n:ssl_cert: /some/ssl/certificate.crt\n:ssl_key: /some/ssl/key.key\n",
            'mode' => '0440',
            'owner' => 'puppet',
            'group' => 'puppet',
          )
        }
      end
    end
  end
end

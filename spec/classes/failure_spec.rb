# frozen_string_literal: true

require 'spec_helper'

describe 'logstash_tcp_reporter' do
  let(:facts) do
    {
      is_pe: false,
    }
  end

  context 'with invalid host parameter' do
    let(:params) do
      {
        host: 'hostname.',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Class\[Logstash_tcp_reporter\]: parameter 'host' expects a Stdlib::Host = Variant\[Stdlib::Fqdn = Pattern\[})
    }
  end

  context 'with invalid port parameter' do
    let(:params) do
      {
        port: 111_337,
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Class\[Logstash_tcp_reporter\]: parameter 'port' expects a Stdlib::Port = Integer\[0, 65535\] value, got Integer\[111337, 111337\]})
    }
  end

  context 'with invalid timeout parameter' do
    let(:params) do
      {
        timeout: '24',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Class\[Logstash_tcp_reporter\]: parameter 'timeout' expects an Integer value, got String})
    }
  end

  context 'with only ssl_cert parameter' do
    let(:params) do
      {
        ssl_enable: true,
        ssl_cert: '/some/ssl/certificate.crt',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{You cannot set only parameter ssl_cert, you have set also parameter ssl_key!})
    }
  end

  context 'with only ssl_key parameter' do
    let(:params) do
      {
        ssl_enable: true,
        ssl_key: '/some/ssl/key.key',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{You cannot set only parameter ssl_key, you have set also parameter ssl_cert!})
    }
  end
end

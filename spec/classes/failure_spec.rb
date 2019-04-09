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
        logstash_host: 'hostname.',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Evaluation Error: Error while evaluating a Resource Statement, Class\[Logstash_tcp_reporter\]: parameter 'logstash_host' expects a Stdlib::Host = Variant\[Stdlib::Fqdn = Pattern\[})
    }
  end

  context 'with invalid port parameter' do
    let(:params) do
      {
        logstash_port: 111_337,
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Evaluation Error: Error while evaluating a Resource Statement, Class\[Logstash_tcp_reporter\]: parameter 'logstash_port' expects a Stdlib::Port = Integer\[0, 65535\] value, got Integer\[111337, 111337\]})
    }
  end

  context 'with invalid timeout parameter' do
    let(:params) do
      {
        logstash_timeout: '24',
      }
    end

    it {
      expect(subject).to compile.and_raise_error(%r{Evaluation Error: Error while evaluating a Resource Statement, Class\[Logstash_tcp_reporter\]: parameter 'logstash_timeout' expects an Integer value, got String})
    }
  end
end

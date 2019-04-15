# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'logstash_tcp_reporter' do
  let(:manifest) do
    <<-INCLUDE_CLASS
      include logstash_tcp_reporter
    INCLUDE_CLASS
  end

  it 'runs first time with changes and without errors' do
    expect(apply_manifest(manifest, catch_failures: true).exit_code).to eq 2
  end

  it 'runs a second time without changes' do
    expect(apply_manifest(manifest, catch_changes: true).exit_code).to eq 0
  end

  describe file('/etc/puppetlabs/puppet/logstash_tcp.yaml') do
    it { is_expected.to be_file }
    it { is_expected.to contain ':host: 127.0.0.1' }
    it { is_expected.to contain ':port: 5999' }
    it { is_expected.to contain ':timeout: 10' }
    it { is_expected.to contain ':ssl_enable: Off' }
  end
end

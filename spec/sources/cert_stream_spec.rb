# frozen_string_literal: true

require "mock_redis"

RSpec.describe Ayashige::Sources::CertStream, :vcr do
  subject { Ayashige::Sources::CertStream.new }

  let(:redis) { MockRedis.new }

  before do
    allow(Ayashige::Redis).to receive(:client).and_return(redis)
  end

  after do
    redis.flushdb
  end

  describe "#store_newly_registered_domains" do
    let(:domain_name) { "paypal.pay.pay.com" }
    let(:not_before) { 1544757209 }
    it "should store suspicious domains into Redis" do
      output = capture(:stdout) do
        subject.store_newly_registered_domains(
          all_domains: [domain_name],
          not_before: not_before
        )
      end
      expect(output.include?(domain_name)).to eq(true)
      expect(redis.exists(domain_name)).to eq(true)
    end
  end
end

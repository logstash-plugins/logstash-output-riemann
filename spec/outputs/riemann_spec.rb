require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin"
require "logstash/json"

describe "outputs/riemann" do

  context "registration" do

    it "should register" do
      output = LogStash::Plugin.lookup("output", "riemann").new
      expect {output.register}.not_to raise_error
    end

    context "protocol" do
      it "should fail if not set to [tcp] or [udp]" do
        expect {
          output = LogStash::Plugin.lookup("output", "riemann").new("protocol" => "fake")
          output.register
          }.to raise_error
      end

      it "should not error out if set to [tcp]" do
        expect {
          output = LogStash::Plugin.lookup("output", "riemann").new("protocol" => "tcp")
          output.register
          }.not_to raise_error
      end

      it "should not error out if set to [udp]" do
        expect {
          output = LogStash::Plugin.lookup("output", "riemann").new("protocol" => "udp")
          output.register
          }.not_to raise_error
      end

    end
  end

  context "receive" do
    output = LogStash::Plugin.lookup("output", "riemann").new
    data = {"message"=>"hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
    event = LogStash::Event.new data
    it "should accept the event" do
      expect{
        output.receive event
        }.not_to raise_error
    end
  end
end
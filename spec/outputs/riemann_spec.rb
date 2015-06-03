require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin"
require "logstash/json"

describe "outputs/riemann" do
  context "registration" do
    it "should register" do
      output = LogStash::Plugin.lookup("output", "riemann").new
      expect {output.register}.to_not raise_error
    end
  end
end
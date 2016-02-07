require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin"
require "logstash/json"

describe "outputs/riemann" do
  let(:output) { LogStash::Plugin.lookup("output", "riemann").new }
  
  context "registration" do

    it "should register" do
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

    data = {"message"=>"hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
    event = LogStash::Event.new data

    it "should accept the event" do

      expect{
        output.receive event
        }.not_to raise_error
    end

  end


  context "map_fields" do

    context "with basic data" do

      it "will return keys that do not start with @ sign." do
        data = {"message"=>"hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:message=>"hello", :host=>"vagrant-ubuntu-trusty-64"}
        expect(output.map_fields(nil, data)).to eq expected_data
      end

      it "will return a hash of nested values" do
        data = {"message"=>"hello", "node_info" => {"name" => "node1", "status" => "up"}, "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:message =>"hello", :host =>"vagrant-ubuntu-trusty-64", :"node_info.name" => "node1", :"node_info.status" => "up"}
        expect(output.map_fields(nil, data)).to eq expected_data
      end

    end
  end

  context "build_riemann_formatted_event" do

    context "with map_fields" do

      let(:output) { LogStash::Plugin.lookup("output", "riemann").new("map_fields" => "true") }

      it "will return symboled hash with at least :host, :time, and :description" do
        data = {"message"=>"hello", "node_info" => {"name" => "node1", "status" => "up"}, "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:time=>1433374494, :message =>"hello", :description =>"hello", :host =>"vagrant-ubuntu-trusty-64", :"node_info.name" => "node1", :"node_info.status" => "up"}
        event = LogStash::Event.new data
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end

      it "will return a symboled hash with :host value from specified field" do
        data = {"test_hostname" => "node1", "message" => "hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:time=>1433374494, :description =>"hello", :host =>"node1", :test_hostname => "node1", :message => "hello"}
        event = LogStash::Event.new data
        output.sender = "%{test_hostname}"
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end
    end

    context "without map_fields" do

      it "will return symboled hash with at least :host, :time, and :description" do
        data = {"message"=>"hello", "node_info" => {"name" => "node1", "status" => "up"}, "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:time=>1433374494, :description =>"hello", :host =>"vagrant-ubuntu-trusty-64"}
        event = LogStash::Event.new data
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end

      it "will return a symboled hash with :host value from specified field" do
        data = {"test_hostname" => "node1", "message" => "hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:time=>1433374494, :description =>"hello", :host =>"node1"}
        event = LogStash::Event.new data
        output.sender = "%{test_hostname}"
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end
    end

    context "with tags" do

      it "will return a symboled tags with multiple tags" do
        data = {"tags"=> ["good_enough", "smart_enough", "doggone_it", "people_like_me"], "message"=>"hello", "node_info" => {"name" => "node1", "status" => "up"}, "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:tags => ["good_enough", "smart_enough", "doggone_it", "people_like_me"], :time=>1433374494, :description =>"hello", :host =>"vagrant-ubuntu-trusty-64"}
        event = LogStash::Event.new data
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end

    end

    context "with riemann_event" do
      it "will return a symboled hash with overriden description field" do
        data = {"field_a" => "foobar", "message" => "hello", "@version"=>"1", "@timestamp"=>"2015-06-03T23:34:54.076Z", "host"=>"vagrant-ubuntu-trusty-64"}
        expected_data = {:time=>1433374494, :description =>"foobar", :host =>"vagrant-ubuntu-trusty-64"}
        event = LogStash::Event.new data
        output.riemann_event = {"description" => "%{field_a}"}
        expect(output.build_riemann_formatted_event(event)).to eq expected_data
      end
    end
  end
end

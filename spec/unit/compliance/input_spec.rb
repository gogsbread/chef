#
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "spec_helper"
require "tempfile"

describe Chef::Compliance::Input do
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:data) { { "ssh-01" => { "expiration_date" => Date.jd(2463810), "justification" => "waived, yo", "run" => false } } }
  let(:path) { "/var/chef/cache/cookbooks/acme_compliance/compliance/inputs/default.yml" }
  let(:cookbook_name) { "acme_compliance" }
  let(:input) { Chef::Compliance::Input.new(events, data, path, cookbook_name) }

  it "has a cookbook_name" do
    expect(input.cookbook_name).to eql(cookbook_name)
  end

  it "has a path" do
    expect(input.path).to eql(path)
  end

  it "has a pathname based on the path" do
    expect(input.pathname).to eql("default")
  end

  it "is disabled" do
    expect(input.enabled).to eql(false)
    expect(input.enabled?).to eql(false)
  end

  it "has an event handler" do
    expect(input.events).to eql(events)
  end

  it "can be enabled by enable!" do
    input.enable!
    expect(input.enabled).to eql(true)
    expect(input.enabled?).to eql(true)
  end

  it "enabling sends an event" do
    expect(events).to receive(:compliance_input_enabled).with(cookbook_name, input.pathname, path)
    input.enable!
  end

  it "can be disabled by disable!" do
    input.enable!
    input.disable!
    expect(input.enabled).to eql(false)
    expect(input.enabled?).to eql(false)
  end

  it "has a #for_inspec method that renders the path" do
    expect(input.for_inspec).to eql(path)
  end

  it "doesn't render the events in the inspect output" do
    expect(input.inspect).not_to include("events")
  end

  it "inflates objects from YAML" do
    string = <<~EOH
ssh-01:
  expiration_date: 2033-07-31
  run: false
  justification: "waived, yo"
    EOH
    newinput = Chef::Compliance::Input.from_yaml(events, string, path, cookbook_name)
    expect(newinput.data).to eql(data)
  end

  it "inflates objects from files" do
    string = <<~EOH
ssh-01:
  expiration_date: 2033-07-31
  run: false
  justification: "waived, yo"
    EOH
    tempfile = Tempfile.new("chef-compliance-test")
    tempfile.write string
    tempfile.close
    newinput = Chef::Compliance::Input.from_file(events, tempfile.path, cookbook_name)
    expect(newinput.data).to eql(data)
  end

  it "inflates objects from hashes" do
    newinput = Chef::Compliance::Input.from_hash(events, data, path, cookbook_name)
    expect(newinput.data).to eql(data)
  end
end

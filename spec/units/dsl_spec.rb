#
# Copyright 2018,2019,2020 Mark D. Richter
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

require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'dsl')

describe 'Deprovisioner::DSL' do

  before(:each) do
    @dsl = Deprovisioner::DSL.new(DummyLogger.new)
  end

  it 'recognizes invalid commands' do
    expect{@dsl.parse('foo calendar owner from c to e')}.to raise_error(RuntimeError, 'Error - Unrecognized command: "foo"')
  end

  it 'recognizes an empty command string' do
    expect{@dsl.parse('')}.to raise_error(RuntimeError, 'Error - Nothing to do')
  end

  it 'recognizes deprovision commands' do
    command_line = 'deprovision user foo@thoughtworks.com'
    expect(@dsl.parse(command_line)).to eq %w[deprovision_google foo@thoughtworks.com]
  end

  it 'recognizes clear oauth commands for a single user' do
    command_line = 'clear oauth foo-user'
    expect(@dsl.parse(command_line)).to eq %w[clear_oauth_user foo-user]
  end

  it 'recognizes clear oauth commands' do
    command_line = 'clear oauth'
    expect(@dsl.parse(command_line)).to eq %w[clear_oauth]
  end

  it 'recognizes an erroneous clear command' do
    expect{@dsl.parse('clear blah foo-user')}.
        to raise_error(RuntimeError, 'Error - Clear command target must be oauth. I see blah instead.')
  end

  it 'recognizes a get suspended users command' do
    # We assume we can strip OAuth grants from suspended users immediately.
    command_line = 'get suspended users'
    expect(@dsl.parse(command_line)).to eq %w[get_suspended_users]
  end

  it 'recognizes a get deprovisionable users command' do
    # deprovisionable users are those that are suspended,
    # are not already deprovisioned
    # and have not logged in for two weeks or more
    command_line = 'get deprovisionable users'
    expect(@dsl.parse(command_line)).to eq %w[get_deprovisionable_users]
  end

  it 'recognizes a deprovision users command' do
    command_line = 'deprovision users'
    expect(@dsl.parse(command_line)).to eq %w[deprovision_users]
  end

  it 'recognizes get aliases' do
    command_line = 'get aliases'
    expect(@dsl.parse(command_line)).to eq %w[get_all_aliases]
	end

	it 'recognizes set_group_property commands' do
    command_line = 'set_group_property a b c'
		expect(@dsl.parse(command_line)).to eq ['set_group_property', 'a', 'b', 'c']
	end

end

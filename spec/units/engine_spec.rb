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

module Deprovisioner
  require File.join(File.dirname(__FILE__), '..', 'spec_helper')
  require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'google')
  require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'gam')
  require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'engine')
  require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'engine_config')
  require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'dsl')

  describe 'Deprovisioner::Engine' do

    before(:all) do
      @log = DummyLogger.new
      @results_dir = File.join(File.dirname(__FILE__), '..', 'results')
      @config = EngineConfig.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'config', 'config.yml'))
    end

    before(:each) do
      @google = Google.new(@config.google_features, @log, nil)
      @google.gam = double(GAM)
      @identity = Deprovisioner::Engine.new(nil, @log, @config)
      @identity.google = @google
    end

    it 'deprovisions google user' do
      command = 'deprovision user foo@bar.com'
      expect(@google).to receive(:deprovision_google_account).with('foo@bar.com', '/Former employees', true)
      @identity.run(command)
    end

    it 'unsubscribes an account from a bunch of groups' do
      command = 'unsubscribe groups foo-user'
      expect(@google).to receive(:unsubscribe_groups).with('foo-user')
      @identity.run(command)
    end

    it 'it resets oauth of a google user' do
      command = 'clear oauth foo-user'
      expect(@google).to receive(:unsubscribe_oauth_user).with('foo-user')
      @identity.run(command)
    end

    it 'resets oauth for all suspended users' do
      command = 'clear oauth'
      expect(@google).to receive(:unsubscribe_oauth)
      @identity.run(command)
    end

    it 'gets suspended users' do
      command = 'get suspended users'
      expect(@google).to receive(:get_suspended_users)
      @identity.run(command)
    end

    it 'gets deprovisionable users' do
      command = 'get deprovisionable users'
      expect(@google).to receive(:get_deprovisionable_users)
      @identity.run(command)
    end

    it 'deprovisions users according to rules' do
      command = 'deprovision users'
      expect(@google).to receive(:deprovision_google_users)
      @identity.run(command)
		end

		it 'sets group properties' do
			command = 'set_group_property a b c'
			expect(@google).to receive(:set_group_property).with('a', 'b', 'c')
			@identity.run(command)
		end

  end
end

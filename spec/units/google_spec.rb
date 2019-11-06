#
# Copyright 2018,2019 Mark D. Richter
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
  describe 'Deprovisioner::Google' do

    require File.join(File.dirname(__FILE__), '..', 'spec_helper')
     require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'gam')

    before(:all) do
      @alias_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'aliases-test.csv')
      @nil_alias_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'no-aliases-test.csv')
      @features = DummyFeatures.new(
          'google_delegate_calendar' => true,
          'google_deprovision_user' => true,
          'google_unsubscribe_groups' => true,
          'google_reset_oauth' => true,
          'google_get_suspended_users' => true,
          'google_get_deprovisionable_users' => true,
          'google_deprovision_users' => true,
          'google_assign_vfe_license' => true
      )
    end

    before(:each) do
      @google = Google.new(@features, DummyLogger.new, nil)
      @google.gam = double(GAM)
    end

    it 'gets the list of users' do
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with('print users')
      @google.get_users
    end

    it 'gets the list of oauth client ids for a user' do
      allow(@google).to receive_messages(:file_to_array => fake_tokens)
      expect(@google.gam).to receive(:run).exactly(1).times
          .with('gam user foo_user show tokens')
          .and_return(File.join(File.dirname(__FILE__), '..', 'fixtures', 'tokens.txt'))
      client_ids = @google.get_oauth_client_ids('foo_user')
      expect(client_ids.length).to eq 5
      expect(client_ids[1]).to eq '"222"'
    end

    it 'runs a domain-specific command and gets a results file' do
      command_line = 'info domain'
      expect(@google.gam).to receive(:run).with(command_line)
      @google.run(command_line)
    end

    it 'gets list of suspended userids' do
      command_line = 'gam print users suspended lastlogintime query isSuspended=true'
      allow(@google).to receive_messages(:parse_for_suspended_users => [])
      expect(@google.gam).to receive(:run).with(command_line)
      @google.get_suspended_users
    end

    it 'unsubscribes oauth for all suspended users' do
      command_line = 'gam print users suspended lastlogintime query isSuspended=true'
      allow(@google).to receive_messages(:parse_for_suspended_users => [%w[a 2014-12-18], %w[b 2014-12-01], %w[c 2014-12-02]])
      expect(@google.gam).to receive(:run).with(command_line)
      expect(@google).to receive(:unsubscribe_oauth_user).with('a')
      expect(@google).to receive(:unsubscribe_oauth_user).with('b')
      expect(@google).to receive(:unsubscribe_oauth_user).with('c')
      @google.unsubscribe_oauth
    end

    it 'gets list of account IDs that can be deprovisioned' do
      command_line = 'gam print users suspended lastlogintime query isSuspended=true'
      allow(@google).to receive_messages(:parse_for_suspended_users => [%w[a 2014-12-18], %w[b 2014-12-01], %w[c 2014-12-02]])
      expect(@google.gam).to receive(:run).with(command_line)
      expect(@google.get_deprovisionable_users).to eq %w[a b c]
    end

    it 'delegates calendar privileges' do
      command = 'calendar cal@foo.com add owner foo_user@foo.com'
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with(command)
      @google.delegate_calendar('cal@foo.com', 'owner', 'foo_user@foo.com')
    end

    it 'deprovisions @google accounts' do
      aliases_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'aliases-test.csv')
      groups_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'groups.csv')
      tokens_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'tokens.txt')
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with('gam print users groups query "email:foo-user"')
        .and_return(groups_file)
      expect(@google.gam).to receive(:run).with('gam update group a-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group b-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group c-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam user foo-user show tokens').and_return(tokens_file)
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "111"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "222"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "333"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "444"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "555"')
      expect(@google.gam).to receive(:run).with('gam update user foo-user email vfe.145.foo-user')
      expect(@google.gam).to receive(:run).with('gam print users aliases query "email:vfe.145.foo-user"').and_return(aliases_file)
      expect(@google.gam).to receive(:run).with('gam delete alias foo1')
      expect(@google.gam).to receive(:run).with('gam delete alias foo2')
      expect(@google.gam).to receive(:run).with('gam delete alias foo3')
      expect(@google.gam).to receive(:run).with('gam user vfe.145.foo-user add license Google-Vault-Former-Employee')
      expect(@google.gam).to receive(:run).with('gam update user vfe.145.foo-user org "/Former employees"')
      @google.deprovision_google_account('foo-user', '/Former employees', true)
    end

    it 'deprovisions google accounts without archiving' do
      groups_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'groups.csv')
      tokens_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'tokens.txt')
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with('gam print users groups query "email:foo-user"')
        .and_return(groups_file)
      expect(@google.gam).to receive(:run).with('gam update group a-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group b-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group c-group@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam user foo-user show tokens').and_return(tokens_file)
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "111"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "222"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "333"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "444"')
      expect(@google.gam).to receive(:run).with('gam user foo-user delete token clientid "555"')
      @google.deprovision_google_account('foo-user', nil, false)
    end

    it 'removes the list of aliases from a user' do
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with('gam print users aliases query "email:foo@thoughtworks.org"').and_return(@alias_file)
      expect(@google.gam).to receive(:run).with('gam delete alias foo1')
      expect(@google.gam).to receive(:run).with('gam delete alias foo2')
      expect(@google.gam).to receive(:run).with('gam delete alias foo3')
      @google.remove_aliases('foo@thoughtworks.org')
      expect(@google.gam).to receive(:run).with('gam print users aliases query "email:foo@thoughtworks.org"').and_return(@nil_alias_file)
      @google.remove_aliases('foo@thoughtworks.org')
    end

    it 'fetches an array of aliases' do
      aliases = @google.aliases(@alias_file)
      expect(aliases.inspect).to eq '["foo1", "foo2", "foo3"]'
    end

    it 'assigns a license to a user' do
      allow(@google).to receive_messages(:file_to_array => nil)
      expect(@google.gam).to receive(:run).with('gam user foo-user add license foo-license')
      @google.add_license('foo-user', 'foo-license')
    end

    it 'returns list of groups of which a user is a member' do
      file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'groups.csv')
      expect(@google.gam).to receive(:run)
        .with('gam print users groups query "email:foo-user@thoughtworks.com"')
      .and_return(file)
      groups = @google.groups('foo-user@thoughtworks.com')
      expect(groups.length).to eq 3
      expect(groups[0]).to eq 'a-group@thoughtworks.com'
      expect(groups[1]).to eq 'b-group@thoughtworks.com'
      expect(groups[2]).to eq 'c-group@thoughtworks.com'
    end

    it 'unsubscribes an account from a bunch of groups' do
      allow(@google).to receive(:groups).with('foo-user').and_return(%w[a@thoughtworks.com b@thoughtworks.com c@thoughtworks.com d])
      expect(@google.gam).to receive(:run).with('gam update group a@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group b@thoughtworks.com remove foo-user')
      expect(@google.gam).to receive(:run).with('gam update group c@thoughtworks.com remove foo-user')
      @google.unsubscribe_groups('foo-user')
    end

    it 'wipes a users calendar' do
      expect(@google.gam).to receive(:run).with('gam calendar foo-user wipe')
      @google.wipe_calendar('foo-user')
    end

    it 'deprovisions all deprovisionable users' do
      allow(@google).to receive(:get_deprovisionable_users).and_return(%w[a b])
      expect(@google).to receive(:get_deprovisionable_users)
      allow(@google).to receive(:deprovision_google_account)
      @google.deprovision_google_users('/Former employees', true)
    end

    it 'gets all aliases' do
      expect(@google.gam).to receive(:run).with('gam print aliases')
      @google.get_all_aliases
    end

    it 'renames the account' do
      allow(@google.gam).to receive (:run)
      expect(@google.change_email('foo')).to eq('vfe.145.foo')
      @google.change_email('foo')
    end

  end

end
def fake_tokens
['Tokens for foo@thoughtworks.org:',
 ' Client ID: Google Chrome',
 ' scopes:',
 '  https://www.google.com/accounts/OAuthLogin',
 ' displayText: Google Chrome',
 ' userKey: 1234',
 '',
 ' Client ID: 99212824970-5e8llha9d5ue4dpkaasmhta5mlk1taq6.apps.googleusercontent.com',
 ' scopes:',
 '  https://www.googleapis.com/auth/admin.reports.usage.readonly',
 ' displayText: GAM',
 ' userKey: 1234']
end

def fake_clients
 ['Client ID: Google Chrome', 'Client ID: 99212824970-5e8llha9d5ue4dpkaasmhta5mlk1taq6.apps.googleusercontent.com']
end

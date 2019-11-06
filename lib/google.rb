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

  class Google
    require 'fileutils'
    require 'csv'
    require File.join(File.dirname(__FILE__), 'logging.rb')
    require File.join(File.dirname(__FILE__), 'gam.rb')
    attr_accessor :gam

    def initialize(features, log, gam_location=nil)
      log.info 'Identity::Google created'
      FileUtils.mkdir_p('results')
      @test = gam_location
      @log = log
      @features = features
      @gam_location = gam_location
      @gam =  GAM.new(log, gam_location) unless gam_location.nil?
      @ticks = Time.new.to_i
      @ticks = 145 if gam_location.nil?
    end

    def deprovision_google_account(email, org, archive)
      unless @features.has_feature?('google_deprovision_user')
        put_console "Skipping Google account deprovisioning for #{email}, because feature 'google_deprovision_user' is not enabled."
        return
      end
      put_console "Deprovisioning #{email} into #{org}"
      unsubscribe_groups(email)
      unsubscribe_oauth_user(email)
      new_email = archive ? change_email(email) : ' '
      remove_aliases(new_email) if archive
      add_license(new_email, 'Google-Vault-Former-Employee') if archive
      change_org(new_email, "#{org}") if archive
      put_console "Deprovisioned #{email} as #{new_email} into #{org}"
      nil
    end

    def deprovision_google_users(location, archive)
      unless @features.has_feature?('google_deprovision_users')
        put_console "Skipping all Google deprovisioning, because feature 'google_deprovision_users' is not enabled."
        return
      end
      get_deprovisionable_users.each {|account| deprovision_google_account(account, location, archive)}
    end

    def change_email(email)
      new = "vfe.#{@ticks}.#{email}"
      command = "gam update user #{email} email #{new}"
      @gam.run(command)
      put_console "renamed #{email} as #{new}"
      new
    end


    def change_org(email, org)
      result = @gam.run("gam update user #{email} org \"#{org}\"")
      put_console("Moved #{email} to #{org}")
      result
    end

    def unsubscribe_groups(email)
      unless @features.has_feature?('google_unsubscribe_groups')
        put_console "Leaving groups for #{email} alone, because feature 'google_unsubscribe_groups' is not enabled."
        return
      end
      groups = groups(email)
      put_console "Found #{groups.length} groups for #{email}"
      groups.each {|group| put_console group.inspect}
      groups.each do |group|
        @gam.run("gam update group #{group} remove #{email}") if group.include? '@thoughtworks.com'
        put_console "Removed #{email} from group #{group}"
      end
    end

    def unsubscribe_groups_suspended_users
      get_suspended_users.each {|user| unsubscribe_groups(user[0]) if user[1].upcase != 'NEVER'}
    end

    def delegate_calendar(calendar, privilege, user)
      unless @features.has_feature?('google_delegate_calendar')
        put_console "Skipping delegation of Google calendar for #{calendar} with #{privilege} to #{user}, because feature 'google_delegate_calendar' is not enabled."
        return
      end
      command = "calendar #{calendar} add #{privilege} #{user}"
      file_name = @gam.run(command)
      file_to_array(file_name)
    end

    def get_users
      file_name = @gam.run('print users')
      file_to_array(file_name)
    end

    def get_oauth_client_ids(user)
      command_line = "gam user #{user} show tokens"
      put_console command_line
      client_ids = []
      file = @gam.run(command_line)
      return client_ids unless File.exists?(file)
      File.open(file, 'r') do |fi|
        fi.each_line do |l|
          client_ids << "\"#{l.split(':')[1].strip}\"" if l.split(':')[0].strip.start_with?('Client ID')
        end
      end
      client_ids
    end

    def file_to_array(file_name)
      data = []
      File.open(file_name, 'r').each_line do |line|
        data << line.strip
      end
      data
    end

    def get_suspended_users
      command_line = 'gam print users suspended lastlogintime query isSuspended=true'
      put_console command_line
      file_name = @gam.run command_line
      parse_for_suspended_users(file_name)
    end

    def parse_for_suspended_users(file_name)
      users = []
      CSV.foreach(file_name) do |row|
        if row[1].upcase == 'TRUE' && !row[0].match(/^vfe./)
          @log.debug "SUSPENDED USER => #{row[0]} last seen on #{row[3]}"
          users << [row[0],row[3].split('T')[0]]
        end
      end
      users
    end

    def get_deprovisionable_users
      su = get_suspended_users
      du = []
      su.each do |u|
        username = u[0]
        last_login_date = u[1]
        if is_deprovisionable_based_on_last_login(last_login_date)
          du << username
          @log.debug "DEPROVISIONABLE USER => #{username} last seen on #{last_login_date}"
        end
      end
      du
    end

    def is_deprovisionable_based_on_last_login(last_login_date)
      return false if last_login_date.upcase == 'NEVER'
      return (Date.today - Date.parse(last_login_date)) > 30
    end

    def aliases(file_name)
      # Only handle a single row of aliases (one email account) at a time
      i = 0
      CSV.foreach(file_name) do |row|
        if i == 1
          return row[1..99]
        end
        i = i + 1
      end
    end

    def remove_aliases(email)
      command = "gam print users aliases query \"email:#{email}\""
      alias_file = @gam.run(command)
      aliases = aliases(alias_file)
      put_console "Found #{aliases.length} aliases for #{email}"
      @log.debug "Alias file: #{alias_file}"
      @log.debug "Aliases: #{aliases.inspect} "
      aliases.each do |name|
        if name
          @gam.run("gam delete alias #{name}")
          put_console "Removed alias #{name} from #{email}"
        end
      end
      nil
    end

    def unsubscribe_oauth_user(email)
      clients = get_oauth_client_ids(email)
      put_console "Found #{clients.length} OAuth clients for #{email}"
      unless @features.has_feature?('google_reset_oauth')
        put_console "Skipping removal of #{clients.length} OAuth client authorizations for #{email}, because the feature 'google_reset_oauth' is not enabled."
      end
      clients.each do |client|
        command = "gam user #{email} delete token clientid #{client}"
        put_console(command)
        if @features.has_feature?('google_reset_oauth')
          @gam.run(command)
          put_console("Removed access of #{email} to OAuth client id #{client}")
        else
          put_console("Did not remove #{client} from #{email} because feature is not enabled.")
        end
      end
      nil
    end

    def unsubscribe_oauth
      get_suspended_users.each {|u| unsubscribe_oauth_user(u[0])}
    end

    def set_group_property(group, property, setting)

    end

    def add_license(email, license)
      unless @features.has_feature?('google_assign_vfe_license')
        put_console "Skipping assignment of #{license} to #{email}, because feature 'google_assign_vfe_license' is not enabled."
        return
      end
      @gam.run("gam user #{email} add license #{license}")
      put_console "Changed license of #{email} to SKU #{license}"
    end

    def groups(email)
      i = 0
      array = []
      file_name = @gam.run("gam print users groups query \"email:#{email}\"")
      CSV.foreach(file_name) do |row|
        if i > 0
          row.each {|a| array << a}
          break
        end
        i = i + 1
      end
      array[1].nil? ? [] : array[1].split(' ')
    end

    def get_all_aliases
      @gam.run('gam print aliases')
    end

    def wipe_calendar(user)
      @gam.run "gam calendar #{user} wipe"
    end

    def run(command)
      put_console command
      @gam.run command
    end

    def put_console(text)
      @log.info("Google: #{text}")
      puts text unless @test.nil?
    end
  end
end

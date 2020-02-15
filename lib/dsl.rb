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
  class DSL

    require File.join(File.dirname(__FILE__), 'identity', 'version.rb')

    IGNORE = 'ignore'

    def initialize(log)
      @log = log
      @delegation_subjects = %w[calendar mail]
      @calendar_rights = %w[freebusy read editor owner]
    end

    def parse(command_line)
      @log.info "Parsing: \"#{command_line}\" "

      @command_line = command_line

      if command_line.nil? || command_line.strip.length == 0
        report_error 'Nothing to do'
      end

      tokens = command_line.split(' ')
      command = tokens[0]
      @log.debug "The command is \"#{command}\""
      subject = tokens.length < 2 ? '' : tokens[1]
      @log.debug "The command subject is \"#{subject}\""

      case command

        when 'help'
          help
          return IGNORE

        when '-h'
          help
          return IGNORE

        when '--h'
          help
          return IGNORE

        when 'gam'
          ['run_gam', command_line]

        when 'version'
          msg = "ThoughtWorks Deprovisioning Manager Version #{Version.new.version}"
          @log.info msg
          puts msg
          return

        when 'set_group_property'
          ['set_group_property', tokens[1], tokens[2], tokens[3]]

        when 'deprovision'

          case subject

            when 'users'
              %w[deprovision_users]

            when 'user'
              # This is where we'll return an array of commands to deprovision various systems, google, AD, etc.
              commands = ['deprovision_google', tokens[2]]
              @log.info commands.inspect
              commands

            when nil
              report_error "Incomplete command: \"#{command_line}\"" unless tokens.length > 2

            else
              report_error "Deprovision subject must be user. I see \"#{subject}\" instead." unless %w[user].include? subject
          end

        when 'unsubscribe'

          case tokens[1]

            when 'groups'
              ['unsubscribe_groups', tokens[2]]

            else
              report_error "Unsubscribe target must be 'groups'. I see \"#{tokens[1]} instead.\"" unless %w[groups].include? tokens[1]
          end

        when 'clear'

          case tokens[1]

            when 'oauth'
              tokens.length > 2 ? ['clear_oauth_user', tokens[2]] : ['clear_oauth']
            else
              report_error "Clear command target must be oauth. I see #{tokens[1].strip} instead."
          end

        when 'get'

          case subject

            when 'suspended'
              %w[get_suspended_users]

            when 'deprovisionable'
              %w[get_deprovisionable_users]

            when 'aliases'
              %w[get_all_aliases]
            else
              report_error "Get takes \"suspended\" or \"deprovisionable\". I see \"#{subject}\""
          end

        else
          report_error "Unrecognized command: \"#{tokens[0]}\""

      end

    end

    def report_error(message)
      error =  'Error - ' + message
      @log.error error
      raise error
    end

    def help
      File.open(File.join(File.dirname(__FILE__), '..', 'docs', 'help.txt'), 'r') do |l|
        while one_line = l.gets
          puts one_line
        end
      end
    end
  end
end

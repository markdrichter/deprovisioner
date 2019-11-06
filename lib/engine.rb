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

  class Engine
    require 'rubygems'
    require File.expand_path(File.join(File.dirname(__FILE__), 'google.rb'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'logging.rb'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'engine_config.rb'))
    require File.expand_path(File.join(File.dirname(__FILE__), 'dsl.rb'))
    attr_accessor :google

    def initialize(results, log, config)
      log.info 'Identity::Engine created'
      @test = @google
      @results = results
      @log = log
      @config = config
      @log.debug "config => #{config.inspect}"
      @log.debug "config.google_features => #{@config.google_features.inspect}"
      @google = Google.new(@config.google_features, log, @config.gam_location) if @google.nil?
    end

    def run(command)
      begin
        parsed_command = DSL.new(@log).parse(command)
        return if parsed_command.nil?

        verb = parsed_command[0]
      rescue RuntimeError => re
        puts re.message
        raise re
      end
      @log.debug "engine.run first command token is => #{verb.inspect}"
      case verb

      when 'deprovision_google' 
        @google.deprovision_google_account(parsed_command[1], @config.vfe_org, true)

      when 'unsubscribe_groups'
        parsed_command[1].nil? ? @google.unsubscribe_groups_suspended_users : @google.unsubscribe_groups(parsed_command[1])

      when 'clear_oauth_user'
        @google.unsubscribe_oauth_user(parsed_command[1])

      when 'clear_oauth'
        @google.unsubscribe_oauth

      when 'get_suspended_users'
        @google.get_suspended_users

      when 'get_deprovisionable_users'
        @google.get_deprovisionable_users

      when 'deprovision_users'
        @google.deprovision_google_users(@config.vfe_org, true)

      when 'get_all_aliases'
        @google.get_all_aliases

      when 'set_group_property'
        @google.set_group_property(parsed_command[1], parsed_command[2], parsed_command[3])

      else
        @log.error "#{verb} is not a valid command."

      end
    end

  end

  if $PROGRAM_NAME == __FILE__

    begin
      config_file = 'config.yml'
      unless File.exists?(config_file)
        msg = 'config.yml is missing'
        Log.new.error msg
        puts msg
        exit!
      end

      config = EngineConfig.new(config_file)
      log = Log.new
      log.info "\nBegin..."
      command = ''

      ARGV.each {|arg| command = "#{command} #{arg}"}
      log.info "Trying to run Identity::Engine using config => #{config.inspect} and (#{command})"

      result = Engine.new(nil, log, config).run(command)

      Kernel.exit!(0) if result == 'ignore' || result.nil? || result.empty?

      case result.class.to_s
      when 'String'
        File.open(result, 'r') do |fl|
          while line = fl.gets
            puts line
          end
        end
      when 'Array'
        result.each do |a|
          if a.is_a?(Array)
            r = ''
            a.each do |e|
              r = "#{r}#{e},"
            end
            r[r.length - 1] = ''
            puts r
          else
            puts a
          end
        end
      end

      log.info 'Completed.'
      puts 'Completed.'

    rescue StandardError => e
      unless log
        puts 'The config.yml file is missing.'
        exit!(0)
      end
      log.error e.message
      e.backtrace.each {|line| log.error(line)}
      puts e.message
      puts "Completed with errors. Logged details are here: #{config.log}"
    end
  end
end

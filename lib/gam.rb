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

class GAM
  require 'fileutils'
  def initialize(logger, gam_location)
    @log = logger
    @gam_location = ENV['GAM_LOCATION'].nil? ? gam_location : ENV['GAM_LOCATION']
    @my_mac = ENV['MY_MAC']
  end

  def run(command, timestamp=nil)
    stamp = timestamp.nil? ? Time.now.strftime('%Y-%m-%d-%H-%M-%S-%z') : timestamp
    FileUtils.mkdir_p(File.join(File.dirname(__FILE__), '..', 'results'))
    name = "tgam-results-#{stamp}.txt"
    gam command, name
  end

  def gam(command, name)
    file_name = File.join(File.dirname(__FILE__), '..', 'results', name)
    gam_command = @gam_location + 'gam ' + command.sub('gam','')
    command_line = "#{gam_command} > #{file_name}"
    @log.debug "Running this command: \"#{command_line}\""
    system command_line
    file_name
  end

  def os
    @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error, "unknown os: #{host_os.inspect}"
    end
    )
  end

end
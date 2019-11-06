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

class Log

  require 'httpclient'
  require File.join(File.dirname(__FILE__), 'engine_config.rb')

  def initialize
    @config = EngineConfig.new('config.yml')
  end

  def info message
    log_to_web "#{Time.now} INFO: #{message}"
  end

  def debug message
    log_to_web "#{Time.now} DEBUG: #{message}"
  end

  def error message
    log_to_web "#{Time.now} ERROR: #{message}"
  end

  def log_to_web message
    return unless @config.web_logging
    http = HTTPClient.new
    http.post(@config.web_logging, message)
  end

end

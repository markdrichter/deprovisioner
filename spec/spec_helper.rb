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

require 'rspec'
require 'rspec/expectations'
require 'fileutils'
require File.join(File.dirname(__FILE__), '..', 'lib', 'engine_config')


#FileUtils.rmdir(File.join(File.dirname(__FILE__), 'results'))
FileUtils.mkdir_p(File.join(File.dirname(__FILE__), 'results'))

FileUtils.rm_rf (File.join(File.dirname(__FILE__), '..', 'results'))

class DummyLogger
  def initialize(print_to_console=nil)
    @print_to_console = print_to_console
  end

  def info(str)
    console_out('INFO', str)
  end

  def debug(str)
    console_out('INFO', str)
  end

  def error(str)
    console_out('INFO', str)
  end

  def console_out(level, str)
    puts "#{Time.now} #{level}: #{str}" if @print_to_console
  end
end

class DummyFeatures
  def initialize(features)
    @features = features
  end

  def has_feature?(feature)
    @features[feature].nil? ? false : @features[feature]
  end
end

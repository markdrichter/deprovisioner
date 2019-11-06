#
# Copyright 2018 Mark D. Richter
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

require 'yaml'

class EngineConfig

  attr_reader :google_features

  def initialize(path)
    @yaml = YAML.load_file(path)
    @google_features = Features.new(@yaml['features']['google'])
  end

  def log
    @yaml['log']
  end

  def results
    @yaml['results']
  end

  def vfe_org
    @yaml['vfe_org'].nil? ? '/Former employees' : @yaml['vfe_org']
  end

  def gam_location
    @yaml['gam_location']
  end

  def alias_table
    @yaml['alias_table']
  end

  def local_build
    @yaml['configuration']['local_build']
  end

  def data_location
    @yaml['data_location']
  end
  
  def web_logging
    @yaml['web_logging']
  end

  class Features
    def initialize(features)
      @features = features
    end

    def has_feature?(feature)
      @features[feature].nil? ? false : @features[feature]
    end
  end

end


require 'yaml'

class CouchConfig

  def initialize(config)
      @config = config
  end
  
  def self.create_from_file(config_file)
      CouchConfig.new(YAML.load_file(config_file))
  end
  
  def hostname
    @config["hostname"]
  end
  
  def port
    @config["port"]
  end 
  
  def delta_path
    @config["delta_path"]
  end

  def database
    @config["database"]
  end
  
  def merge_config(config)
    @config = @config.merge(config)
  end
  
end

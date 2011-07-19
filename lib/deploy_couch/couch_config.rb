require 'yaml'

class CouchConfig

  def initialize(config_file)
      @config = YAML.load_file(config_file)
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
  
end

require 'yaml'

class CouchConfig

  def initialize(config)
      @config = config
  end
  
  def self.create_from_file(config_file)
      config = YAML.load_file(config_file)
      config = config.merge("config_folder_path" => File.dirname(config_file))
      CouchConfig.new(config)
  end
  
  def hostname
    @config["hostname"]
  end
  
  def port
    @config["port"]
  end 
  
  def delta_path
    @config["config_folder_path"] + "/" + @config["delta_path"]
  end

  def database
    @config["database"]
  end

  def doc_type_field
    @config["doc_type_field"]
  end

  def type_version_field
    @config["type_version_field"]
  end
  
  def merge_config(config)
    @config = @config.merge(config)
  end
  
end

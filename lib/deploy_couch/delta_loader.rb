module DeployCouch

  class DeltaLoader
    def initialize(deltas_folder)
      @deltas_folder = deltas_folder
    end
  
    def get_deltas
      hash = {}
      files = Dir["#{@deltas_folder}/*.yml"].select {|f| File.file?(f)}
      files.each do |file|
        file_name = File.basename(file)
        key = file_name.split('_')[0].to_i
        if (key == 0) 
          e = RuntimeError.new("invalid file name #{file_name}")
          raise e
        end
        if (hash.has_key?(key)) 
          e = RuntimeError.new("duplicate key found in file #{file_name}")
          raise e
        end
      
        hash[key] = convert_to_delta(key,file) 
      end
      hash
    end
  
    def convert_to_delta(id, file)
      delta_config = YAML.load_file(file)
      file_name = File.basename(file)
      raise "#{file_name} content is not valid " if delta_config['type'].nil? or delta_config['map_function'].nil?
      Delta.new(id,file_name,delta_config['type'],delta_config['map_function'],delta_config['rollback_function'])
    end
  
  end

end
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
      
      hash[key] = file 
    end
    hash
  end
  
end
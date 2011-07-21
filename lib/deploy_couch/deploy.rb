class Deploy
  def initialize(config)
    @config = config    
  end
  
  def run
    repository = Repository.new(@config)
    delta_loader = DeltaLoader.new(@config.delta_path)
    deltas_map = delta_loader.get_deltas
    keys = deltas_map.keys.sort
    keys.each do |key|
      delta = deltas_map[key]
      DeltaProcessor.new(@config,delta,repository).apply
    end  
  end
  
  
end
class Deploy
  def initialize(config)
    @config = config    
  end
  
  def run
    repository = Repository.new(@config)
    delta_loader = DeltaLoader.new(@config.delta_path)
    deltas_map = delta_loader.get_deltas
    couch_schema = CouchDbSchema.load_or_create(@config,repository)
    all_delta_keys = deltas_map.keys.sort    
    applied_deltas = couch_schema.applied_deltas.sort
    last_applied_delta_id = 0
    last_applied_delta_id = applied_deltas[-1] if applied_deltas.count > 0
    delta_keys_to_apply = all_delta_keys.select {|key| key > last_applied_delta_id }
    
    applied_deltas = []
    
    delta_keys_to_apply.each do |key|
      delta = deltas_map[key]
      type = couch_schema.get_next_type_version_for(delta.type)
      DeltaProcessor.new(type,@config,delta,repository).apply
      couch_schema.completed(delta)
      applied_deltas.push(delta)
    end  
    
    applied_deltas
  end
  
  
end
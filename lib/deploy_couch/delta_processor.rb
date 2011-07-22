module DeployCouch

  class DeltaProcessor
    def initialize(next_type_version,config,delta,repository)
      @repository = repository
      @delta = delta
      @config = config
      @next_type_version = next_type_version
    end
  
    def apply
      user_map_function = @delta.map_function.gsub("\"","\\\"")
      map_function = <<-JSON
        {
         "map":"function(doc){if(doc.#{@config.doc_type_field}=='#{@delta.type}' && (!doc.#{@config.type_version_field}  || doc.#{@config.type_version_field} < #{@next_type_version})){new_doc = eval(uneval(doc)); var method = map(new_doc); if(method) emit(method,new_doc);}}
        #{user_map_function}"
        }
      JSON
      @repository.get_documents_to_modify(map_function) do |x|
        update_document(x['value']) if x['key'] == 'update'
        @repository.delete_document(x['value']) if x['key'] == 'delete'
      end
    end
  
    def update_document(json_doc)
      json_doc[@config.type_version_field] = @next_type_version 
      @repository.put_document(json_doc)
    end
  end

end
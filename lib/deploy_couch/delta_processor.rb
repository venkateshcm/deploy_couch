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
      modify_document(map_function,@next_type_version)
    end
    
    def rollback
      user_rollback_function = @delta.rollback_function.gsub("\"","\\\"")
      current_type_version = @next_type_version - 1
      rollback_function = <<-JSON
        {
         "map":"function(doc){if(doc.#{@config.doc_type_field}=='#{@delta.type}' && (doc.#{@config.type_version_field} >= #{current_type_version})){new_doc = eval(uneval(doc)); var method = map(new_doc); if(method) emit(method,new_doc);}}
        #{user_rollback_function}"
        }
      JSON
      modify_document(rollback_function,current_type_version-1)
    end
    
    
private
    def modify_document(function,type_version)
      @repository.get_documents_to_modify(function) do |x|
        update_document(x['value'],type_version) if x['key'] == 'update'
        create_document(x['value'],type_version) if x['key'] == 'create'
        delete_document(x['value'],type_version) if x['key'] == 'delete'
      end
    end
  
    def update_document(json_doc,type_version)
      json_doc[@config.type_version_field] = type_version 
      @repository.put_document(json_doc)
    end
    
    def delete_document(json_doc,type_version)
      @repository.delete_document(json_doc)
    end
    
    def create_document(json_doc,type_version)
      json_doc[@config.type_version_field] = type_version 
      @repository.post_document(json_doc)
    end
    
  end

end
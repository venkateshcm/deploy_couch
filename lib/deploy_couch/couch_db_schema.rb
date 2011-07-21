class CouchDbSchema
  
  def initialize(schema,repository)
    @schema = schema
    @repository = repository
  end
   
  def self.load_or_create(config,repository)
    default_schema = {"_id"=>"schema__schema_document_key__",config.doc_type_field=>"__schema__", 'applied_deltas'=>[], "type_versions"=>{}}
    schema = repository.get_schema
    if (schema.nil?)
       repository.create_schema(default_schema)
       schema = repository.get_schema
    end
    CouchDbSchema.new(schema,repository)
  end
  
  def applied_deltas
    @schema["applied_deltas"]
  end

  def type_versions
    @schema["type_versions"]
  end  
  
  def completed(delta)
    @schema['applied_deltas'].push(delta.id)
    current_type_version = @schema['type_versions'].has_key?(delta.type) ? @schema['type_versions'][delta.type] : 0
    @schema['type_versions'][delta.type] = current_type_version + 1
    
    @repository.put_document(@schema)
    @schema = @repository.get_schema
  end
  
  
end
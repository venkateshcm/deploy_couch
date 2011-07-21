class DeltaProcessor
  def initialize(delta,repository)
    @repository = repository
    @delta = delta
  end
  
  def apply
    map_function = <<-JSON
      {
       "map":"function(doc){if(doc.type=='#{@delta.type}'){new_doc = eval(uneval(doc)); var method = map(new_doc); emit(method,new_doc);}}
      #{@delta.map_function}"
      }
    JSON
    @repository.get_documents(map_function) do |x|
      @repository.put_document(x['value']) if x['key'] == 'update'
    end
  end
  
  
end
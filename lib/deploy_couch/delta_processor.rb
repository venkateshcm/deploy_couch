class DeltaProcessor
  def initialize(type,user_map_function,repository)
    @type = type
    @user_map_function = user_map_function
    @repository = repository
  end
  
  def apply
    map_function = <<-JSON
      {
       "map":"function(doc){if(doc.type=='#{@type}'){new_doc = eval(uneval(doc)); map(new_doc); emit('update',new_doc);}}
      #{@user_map_function}"
      }
    JSON
    @repository.get_documents(map_function) do |x|
      @repository.put_document(x['value'])
    end
  end
  
  
end
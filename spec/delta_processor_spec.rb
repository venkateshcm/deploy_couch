require File.dirname(__FILE__) + '/spec_helper'



describe DeltaProcessor, "execute a delta" do
  it "load relavent documents and apply delta" do
    mock_repository = mock(Repository)
    map_function = <<-JSON
      {
       "map":"function(doc){if(doc.type=='customer'){new_doc = eval(uneval(doc)); map(new_doc); emit('update',new_doc);}}
      function map(doc){ doc.address = 'new address';}"
      }
    JSON
    h={:key=> 'update' , :value=>{:id=>"1",:name=>"name_1", :address=>'new address'}}
    mock_repository.should_receive(:get_documents).with(map_function).and_yield(h)
    mock_repository.should_receive(:put_document).with(h['value'])
    delta = DeltaProcessor.new("customer","function map(doc){ doc.address = 'new address';}",mock_repository)
    delta.apply
  end
end

describe DeltaProcessor, "integration" do  
  it "integration load relavent documents and apply delta" do
    config = CouchConfig.new(File.dirname(__FILE__) + '/couchdb.yml')
    repository = Repository.new(config)
    delta = DeltaProcessor.new("customer","function map(doc){ doc.address = 'new address';}",repository)
    delta.apply
    
    repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
      row['value']["address"].should == 'new address'
    end
  end
  
end
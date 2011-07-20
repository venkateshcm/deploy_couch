require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'


describe DeltaProcessor, "integration" do  
  it "integration load relavent documents and apply delta" do
    config = CouchConfig.new(File.dirname(__FILE__) + '/../couchdb.yml')
    repository = Repository.new(config)
    delta = DeltaProcessor.new("customer","function map(doc){ doc.address = 'new address';}",repository)
    delta.apply
    
    repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
      row['value']["address"].should == 'new address'
    end
  end
  
end
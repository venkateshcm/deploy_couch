require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'


describe DeltaProcessor, "integration" do  
  
  before :all do
    DatabasePopulator.new("test").with_type("customer").with_records(30).build
  end
  
  
  it "integration load relavent documents and apply delta" do
    config = CouchConfig.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
    repository = Repository.new(config)
    delta = Delta.new(1,'file_name',"customer","function map(doc){ doc.address = 'new address'; return 'update'}")
    delta_processor = DeltaProcessor.new(config,delta,repository)
    delta_processor.apply
    
    repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
      row['value']["address"].should == 'new address'
    end
  end
  
end
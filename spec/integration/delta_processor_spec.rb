require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'

module DeployCouch
  
  describe DeltaProcessor, "integration" do  
  
    before :all do
      DatabasePopulator.new("test").with_type("customer").with_records(30).build
    end
  
      
    it "integration load relavent documents and apply delta" do
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      repository = Repository.new(config)
      map_function = "function map(doc){ doc.address = 'new address'; return 'update';}"
      rollback_function = "function map(doc){ delete doc.address; return 'update';}"
      delta = Delta.new(1,'file_name',"customer",map_function,rollback_function)
      delta_processor = DeltaProcessor.new(1,config,delta,repository)
      delta_processor.apply
    
      repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
        row['value']["address"].should == 'new address'
      end
    end
    
    it "integration load relavent documents apply delta and rollback" do
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      repository = Repository.new(config)
      map_function = "function map(doc){ doc.address = 'new address'; return 'update';}"
      rollback_function = "function map(doc){ delete doc.address; return 'update';}"
      delta = Delta.new(1,'file_name',"customer",map_function,rollback_function)
      delta_processor = DeltaProcessor.new(1,config,delta,repository)
      delta_processor.apply
    
      repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
        row['value']["address"].should == 'new address'
      end
      
      delta_processor.rollback
      
      repository.get_documents("{\"map\":\"function (doc){if(doc.type=='customer'){emit(null,doc);}}\"}") do |row|
        row['value'].has_key?("address").should == false
      end
      
      
    end
    
  
  end
  
end
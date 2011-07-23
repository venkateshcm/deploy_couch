require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'

module DeployCouch

  describe Deploy, "load and execute deltas" do
    before :all do
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      default_schema = {"_id"=>"schema__schema_document_key__",config.doc_type_field=>"__schema__", 'applied_deltas'=>[1,11], "type_versions"=>{'customer'=>3}}
      DatabasePopulator.new("test").with_type("customer").with_schema(default_schema).with_records(30).build
    end
  
  
    it "load and execute deltas" do    
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      deploy = Deploy.new(config)
      deltas = deploy.run
      deltas.count.should == 2
      deltas[0].file_name.should == "12_delete_customer_name_1.yml"
      
    end
  end
  
  describe Deploy, "load and execute deltas first database" do
  
    before :all do
      DatabasePopulator.new("test").with_type("customer").with_records(30).build
    end
  
    it "load and execute deltas" do    
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      deploy = Deploy.new(config)
      deltas = deploy.run
      deltas.count.should == 5
      deltas[0].file_name.should == "1_add_address_to_customer.yml"    
    end
  end

  describe Deploy, "execute deltas and rollback all deltas" do
  
    before :all do
      DatabasePopulator.new("test").with_type("customer").with_records(30).build
    end
  
    it "load and execute deltas" do    
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      deploy = Deploy.new(config)
      deploy.run      
      deltas = deploy.rollback
      deltas.count.should == 5
      deltas[0].file_name.should == "13_copy_and_create_new_customer.yml"    
    end
  end


end
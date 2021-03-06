require File.dirname(__FILE__) + '/../spec_helper'

module DeployCouch
  describe Config, "read couch db config" do
    it "should load hostname from couchdb.yml" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').hostname.should == "localhost"
    end
  
    it "should load portnumber from couchdb.yml" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').port.should == 5984
    end
  
    it "should load delta path" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').delta_path.should == File.dirname(__FILE__) + "/../integration/deltas"
    end

    it "should load database name" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').database.should == "test"
    end

    it "should load document type field" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').doc_type_field.should == "type"
    end

    it "should load type version field" do
      Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml').type_version_field.should == "type_version"
    end


    it "should merge config with passed in values" do
      config = Config.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      config.merge_config("database"=>"db")
      config.database.should == "db"
    end

    it "should fail with an exception when config file is not found" do
      lambda { Config.create_from_file(File.dirname(__FILE__) + '/../couchdb1.yml') }.should raise_error()
    end

  end
end
require File.dirname(__FILE__) + '/spec_helper'

describe CouchConfig, "read couch db config" do
  it "should load hostname from couchdb.yml" do
    CouchConfig.new(File.dirname(__FILE__) + '/couchdb.yml').hostname.should == "localhost"
  end
  
  it "should load portnumber from couchdb.yml" do
    CouchConfig.new(File.dirname(__FILE__) + '/couchdb.yml').port.should == 12345
  end
  
  it "should load delta path" do
    CouchConfig.new(File.dirname(__FILE__) + '/couchdb.yml').delta_path.should == "/path/to/folder"
  end

  it "should load database name" do
    CouchConfig.new(File.dirname(__FILE__) + '/couchdb.yml').database.should == "db"
  end

  it "should fail with an exception when config file is not found" do
    lambda { CouchConfig.new(File.dirname(__FILE__) + '/couchdb1.yml') }.should raise_error()
  end

  
end
  
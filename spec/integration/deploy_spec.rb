require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'


describe Deploy, "load and execute deltas" do
  
  before :all do
    DatabasePopulator.new("test").with_type("customer").with_records(30).build
  end
  
  
  it "load and execute deltas" do    
    config = CouchConfig.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
    deploy = Deploy.new(config)
    deploy.run
  end
end
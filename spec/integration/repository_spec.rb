require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'

describe Repository, "execute a delta" do
  
  it "hit couchdb and load relavent documents to apply delta" do
      map_function = '{"map":"function(doc) {emit(doc._id,doc);}"}'
      mock_config = mock(CouchConfig)
      mock_config.should_receive(:hostname).and_return("localhost")
      mock_config.should_receive(:port).and_return(5984)
      mock_config.should_receive(:database).and_return("db")
      repository = Repository.new(mock_config)
      rows = []
      repository.get_documents(map_function) do |row|
        rows.push(row)
      end
      rows.count.should == 2
    end
    
  
end
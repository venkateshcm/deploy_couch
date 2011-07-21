require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/database_populator'

describe Repository, "execute a delta" do
  
  before :all do
    DatabasePopulator.new("db").with_type("customer").with_records(2).build
  end
  
  
  it "hit couchdb and load relavent documents to apply delta" do
      map_function = '{"map":"function(doc) {emit(doc._id,doc);}"}'
      config = CouchConfig.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
      config.merge_config({"database"=>"db"})
      repository = Repository.new(config)
      rows = []
      repository.get_documents(map_function) do |row|
        rows.push(row)
      end
      rows.count.should == 2
    end
    
     it "create schema document if it does not exist and get schema to verify" do
       config = CouchConfig.create_from_file(File.dirname(__FILE__) + '/../couchdb.yml')
       config.merge_config({"database"=>"db"})
       schema =  {"_id"=>"schema__schema_document_key__","type"=>"__schema__", 'applied_deltas'=>[], "type_versions"=>{}}
       repository = Repository.new(config)
       rows = []
       repository.create_schema(schema)
       schema_doc = repository.get_schema
       schema_doc['_id'].should == schema['_id']
       schema_doc['type'].should == schema['type']
       schema_doc['applied_deltas'].should == schema['applied_deltas']
       schema_doc['type_versions'].should == schema['type_versions']
      end

  
end
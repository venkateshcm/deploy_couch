require File.dirname(__FILE__) + '/../spec_helper'

describe CouchDbSchema, "Manage Schema" do

  it "load schema document" do
    repository = mock(Repository)
    repository.should_receive(:get_schema).and_return({"_id"=>"special_key","type"=>"__schema__", 'applied_deltas'=>[1,2], "type_versions"=>{"customer"=>10}})
    schema = CouchDbSchema.load_or_create(get_couchdb_config,repository)
    schema.applied_deltas.should == [1,2]
    schema.type_versions.should == {"customer"=> 10}
  end
  
  it "create if schema document does not exist" do
    repository = mock(Repository)
    repository.should_receive(:get_schema).ordered
    repository.should_receive(:create_schema).ordered
    repository.should_receive(:get_schema).ordered.and_return({"_id"=>"special_key","type"=>"__schema__", 'applied_deltas'=>[], "type_versions"=>{}})
    schema = CouchDbSchema.load_or_create(get_couchdb_config,repository)
    schema.applied_deltas.should == []
    schema.type_versions.should == {}
  end

  it "on completion update schema document" do
    schema_doc = {"_id"=>"special_key","type"=>"__schema__", 'applied_deltas'=>[], "type_versions"=>{}}
    updated_schema_doc = {"_id"=>"special_key","type"=>"__schema__", 'applied_deltas'=>[1], "type_versions"=>{'type'=>1}}
    repository = mock(Repository)
    repository.should_receive(:put_document).ordered.with(updated_schema_doc)    
    repository.should_receive(:get_schema).ordered.and_return(updated_schema_doc)    
    schema = CouchDbSchema.new(schema_doc,repository)
    schema.completed(Delta.new(1,'file_name','type','map_function'))
    schema.applied_deltas.should == [1]
    schema.type_versions.should == {'type'=>1}
  end

  
end
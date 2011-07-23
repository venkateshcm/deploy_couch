require File.dirname(__FILE__) + '/../spec_helper'

module DeployCouch
  
  describe DeltaProcessor, "execute a delta" do
    it "load relavent documents and apply delta" do
      mock_repository = mock(Repository)
      map_function = <<-JSON
        {
         "map":"function(doc){if(doc.type=='customer' && (!doc.type_version  || doc.type_version < 1)){new_doc = eval(uneval(doc)); var method = map(new_doc); if(method) emit(method,new_doc);}}
        function map(doc){ doc.address = 'new address';}"
        }
      JSON
      h={'key'=> 'update' , 'value'=>{'id'=>"1",'name'=>"name_1", 'address'=>'new address'}}
      mock_repository.should_receive(:get_documents_to_modify).with(map_function).and_yield(h)
      mock_repository.should_receive(:put_document).with(h['value'].merge({'type_version' => 1}))
      delta = Delta.new(1,'file_name',"customer","function map(doc){ doc.address = 'new address';}",'rollback_function')
      next_type_version = 1
      delta_processor = DeltaProcessor.new(next_type_version,get_couchdb_config,delta,mock_repository)
      delta_processor.apply
    end

    it "load relavent documents and apply delta" do
      mock_repository = mock(Repository)
      map_function = <<-JSON
        {
         "map":"function(doc){if(doc.type=='customer' && (!doc.type_version  || doc.type_version < 11)){new_doc = eval(uneval(doc)); var method = map(new_doc); if(method) emit(method,new_doc);}}
        function map(doc){ doc.address = 'new address';}"
        }
      JSON
      h={'key'=> 'delete' , 'value'=>{'id'=>"1",'name'=>"name_1", 'address'=>'new address'}}
      mock_repository.should_receive(:get_documents_to_modify).with(map_function).and_yield(h)
      mock_repository.should_receive(:delete_document).with(h['value'])
      delta = Delta.new(1,'file_name',"customer","function map(doc){ doc.address = 'new address';}",'rollback_function')
      next_type_version = 11
      delta_processor = DeltaProcessor.new(next_type_version,get_couchdb_config,delta,mock_repository)
      delta_processor.apply
    end

    it "load relavent documents and rollback delta" do
      mock_repository = mock(Repository)
      map_function = <<-JSON
        {
         "map":"function(doc){if(doc.type=='customer' && (doc.type_version >= 10)){new_doc = eval(uneval(doc)); var method = map(new_doc); if(method) emit(method,new_doc);}}
        function map(doc){ delete doc.address; return 'update';}"
        }
      JSON
      h={'key'=> 'update' , 'value'=>{'id'=>"1",'name'=>"name_1", 'address'=>'new address'}}
      mock_repository.should_receive(:get_documents_to_modify).with(map_function).and_yield(h)
      mock_repository.should_receive(:put_document).with(h['value'].merge({'type_version' => 10}))
      delta = Delta.new(1,'file_name',"customer","function map(doc){ doc.address = 'new address';}","function map(doc){ delete doc.address; return 'update';}")
      next_type_version = 11
      delta_processor = DeltaProcessor.new(next_type_version,get_couchdb_config,delta,mock_repository)
      delta_processor.rollback
    end



  end

end
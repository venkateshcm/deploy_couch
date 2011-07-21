require File.dirname(__FILE__) + '/../spec_helper'

def create_json_response(total_rows,num_of_records,offset=0)
  h = {"total_rows"=> total_rows,"offset" => offset, "rows" => []}
  (1..num_of_records).each do |x|
    h["rows"].push({"id"=>x})
  end
  JSON.generate(h)
end

describe Repository, "execute a delta" do
  it "load relavent documents to apply delta" do
     map_function = "{'map':'function(doc){emit(null,doc);}'}"
     mock_server = mock(Couch::Server)
     Couch::Server.should_receive(:new).with("localhost",1234).and_return(mock_server)
     mock_response = mock(Net::HTTPResponse)
     mock_server.should_receive(:post).with("/db/_temp_view?limit=10&skip=0",map_function).and_return(mock_response)
     json = create_json_response(1,1)
     mock_response.should_receive(:body).and_return(json)
     
     repository = Repository.new(get_couchdb_config)
     rows = []
     repository.get_documents(map_function) do |row|
       rows.push(row)
     end
     rows.count.should == 1
   end
   
   it "load relavent documents to apply delta with paging" do
      map_function = "{'map':'function(doc){emit(null,doc);}'}"
      mock_server = mock(Couch::Server)
      Couch::Server.should_receive(:new).with("localhost",1234).and_return(mock_server)
      mock_response = mock(Net::HTTPResponse)
      mock_server.should_receive(:post).with("/db/_temp_view?limit=10&skip=0",map_function).and_return(mock_response)
      json = create_json_response(15,10)
      mock_response.should_receive(:body).and_return(json)

      mock_response = mock(Net::HTTPResponse)
      mock_server.should_receive(:post).with("/db/_temp_view?limit=10&skip=10",map_function).and_return(mock_response)
      json = create_json_response(15,5,10)
      mock_response.should_receive(:body).and_return(json)

      
      repository = Repository.new(get_couchdb_config)
      rows = []
      repository.get_documents(map_function) do |row|
        rows.push(row)
      end
      rows.count.should == 15
    end

    it "put document to update document" do
       json = {"_id"=> 1757, "name" => "name_1"}
       mock_server = mock(Couch::Server)
       Couch::Server.should_receive(:new).with("localhost",1234).and_return(mock_server)
       mock_response = mock(Net::HTTPResponse)
       mock_server.should_receive(:put).with("/db/#{json['_id']}",json.to_json).and_return(mock_response)

       repository = Repository.new(get_couchdb_config)
       rows = []
       repository.put_document(json)
     end

  
end
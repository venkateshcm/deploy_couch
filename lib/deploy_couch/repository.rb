require 'json'

class Repository
  PAGE_SIZE = 10
  
  def initialize(couch_config)
    @config = couch_config
  end
  
  def get_documents(map_function)
    server = Couch::Server.new(@config.hostname,@config.port)
    no_of_records = 0
    page_no = 0
    finish_loading_all = false
    
    while(!finish_loading_all)
      response = server.post("/#{@config.database}/_temp_view?limit=#{PAGE_SIZE}&skip=#{PAGE_SIZE*page_no}",map_function)
      json = JSON.parse(response.body)
      json["rows"].each do |row|
        yield row
      end
      page_no += 1
      no_of_records += json["rows"].count
      finish_loading_all = true if no_of_records >= json["total_rows"]
    end
  end
  
  def put_document(json)
    server = Couch::Server.new(@config.hostname,@config.port)
    server.put("/#{@config.database}/#{json['_id']}",json.to_json)
  end
  
  
end
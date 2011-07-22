module DeployCouch

  class Repository
    PAGE_SIZE = 10
  
    def initialize(couch_config)
      @config = couch_config
    end
  
    def get_documents(map_function)
      server = Server.new(@config.hostname,@config.port)
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

    def get_documents_to_modify(map_function)
      server = Server.new(@config.hostname,@config.port)
      finish_loading_all = false
    
      while(!finish_loading_all)
        response = server.post("/#{@config.database}/_temp_view?limit=#{PAGE_SIZE}",map_function)
        json = JSON.parse(response.body)
        json["rows"].each do |row|
          yield row
        end
        finish_loading_all = json["total_rows"] <= 10
      end
    end

  
    def put_document(json)
      server = Server.new(@config.hostname,@config.port)
      server.put("/#{@config.database}/#{json['_id']}",json.to_json)
    end

    def delete_document(json)
      server = Server.new(@config.hostname,@config.port)
      server.delete("/#{@config.database}/#{json['_id']}?rev=#{json['_rev']}")
    end
  
    def get_schema
      server = Server.new(@config.hostname,@config.port)
      res = server.get("/#{@config.database}/schema__schema_document_key__",{:suppress_exceptions=>true})
      json = JSON.parse(res.body) if res.kind_of?(Net::HTTPSuccess)
    end

    def create_schema(json)
      server = Server.new(@config.hostname,@config.port)
      res = server.post("/#{@config.database}/",json.to_json)
    end
  end
  
end
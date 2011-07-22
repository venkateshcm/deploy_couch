module DeployCouch
  class DatabasePopulator
    def initialize(database)
      @database = database
    end
  
    def with_type(doc_type)
      @doc_type = doc_type
      self
    end
  
    def with_records(no_of_records)
      @no_of_records = no_of_records
      self
    end
  
    def with_schema(schema_json)
      @schema = schema_json
      self
    end
  
    def build
      server = Server.new("localhost",5984)
      res = server.get("/#{@database}/",{:suppress_exceptions=>true})
      server.delete("/#{@database}/") if res.kind_of?(Net::HTTPSuccess)
      server.put("/#{@database}/","")
      (1..@no_of_records).each do |i|
        h = {"name"=> "name_#{i}","type"=>@doc_type}
        server.post("/#{@database}/",JSON.generate(h))
      end
    
      server.post("/#{@database}/",@schema.to_json) if @schema
    
    end    
  end

end
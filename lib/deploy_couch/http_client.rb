module DeployCouch

  class Server
    def initialize(host, port)
      @host = host
      @port = port 
    end

    def delete(uri, options = {:suppress_exceptions=>false})
      request(Net::HTTP::Delete.new(uri),options)
    end

    def get(uri, options = {:suppress_exceptions=>false})
      request(Net::HTTP::Get.new(uri),options)
    end

    def put(uri, json, options = {:suppress_exceptions=>false})
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req,options)
    end

    def post(uri, json, options = {:suppress_exceptions=>false})
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req,options)
    end

    def request(req, options)
      res = Net::HTTP.start(@host, @port) { |http|http.request(req) }
      isError = !res.kind_of?(Net::HTTPSuccess)
      shouldSupress = options[:suppress_exceptions]   
      if isError and !shouldSupress  
        handle_error(req, res)
      end
      res
    end

    private

    def handle_error(req, res)
      e = RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
      raise e
    end
  end
end

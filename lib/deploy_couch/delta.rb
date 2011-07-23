module DeployCouch

  class Delta
    def initialize(id,file_name,type,map_function,rollback_function)
      @id=id
      @file_name = file_name
      @type = type
      @map_function = map_function
      @rollback_function = rollback_function
    end

    def id
      @id
    end

  
    def file_name
      @file_name
    end
  
    def type
      @type
    end
  
    def map_function
      @map_function
    end

    def rollback_function
      @rollback_function
    end

  
  end

end
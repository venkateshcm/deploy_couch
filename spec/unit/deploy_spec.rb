require File.dirname(__FILE__) + '/../spec_helper'

module DeployCouch
  describe Deploy, "load and execute deltas" do
    it "load and execute deltas in correct order" do
      config = get_couchdb_config
      delta = Delta.new(1,'file_name','type','map function')
      delta2 = Delta.new(10,'file_name2','type','map function')
      deltas_map = {1=>delta,10=>delta2}
    
      mock_delta_loader = mock(DeltaLoader)
      DeltaLoader.should_receive(:new).with("/somefolder/path/to/deltas").and_return(mock_delta_loader)
      mock_delta_loader.should_receive(:get_deltas).and_return(deltas_map)

      mock_repository = mock(Repository)
      Repository.should_receive(:new).with(config).and_return(mock_repository)

      mock_delta_processor = mock(DeltaProcessor)
      DeltaProcessor.should_receive(:new).with(1,config,delta,mock_repository).ordered.and_return(mock_delta_processor)    
      mock_delta_processor.should_receive(:apply)

      mock_delta_processor2 = mock(DeltaProcessor)
      DeltaProcessor.should_receive(:new).with(2,config,delta2,mock_repository).ordered.and_return(mock_delta_processor2)    
      mock_delta_processor2.should_receive(:apply)

      mock_couch_db_schema = mock(DbSchema)
      mock_couch_db_schema.should_receive(:applied_deltas).and_return([])
      DbSchema.should_receive(:load_or_create).with(config,mock_repository).ordered.and_return(mock_couch_db_schema) 
      mock_couch_db_schema.should_receive(:get_next_type_version_for).with('type').ordered.and_return(1)   
      mock_couch_db_schema.should_receive(:completed).ordered.with(delta)
      mock_couch_db_schema.should_receive(:get_next_type_version_for).with('type').ordered.and_return(2)
      mock_couch_db_schema.should_receive(:completed).ordered.with(delta2)
    
      deploy = Deploy.new(config)
      deploy.run
    end
  
    it "executes unapplied deltas only in correct order" do
      config = get_couchdb_config
      delta = Delta.new(1,'file_name','type','map function')
      delta2 = Delta.new(10,'file_name2','type','map function')
      deltas_map = {1=>delta,10=>delta2}
    
      mock_delta_loader = mock(DeltaLoader)
      DeltaLoader.should_receive(:new).with("/somefolder/path/to/deltas").and_return(mock_delta_loader)
      mock_delta_loader.should_receive(:get_deltas).and_return(deltas_map)

      mock_repository = mock(Repository)
      Repository.should_receive(:new).with(config).and_return(mock_repository)

      mock_delta_processor = mock(DeltaProcessor)
      DeltaProcessor.should_receive(:new).with(1,config,delta2,mock_repository).and_return(mock_delta_processor)    
      mock_delta_processor.should_receive(:apply)

      mock_couch_db_schema = mock(DbSchema)
      mock_couch_db_schema.should_receive(:applied_deltas).and_return([1])
      DbSchema.should_receive(:load_or_create).with(config,mock_repository).ordered.and_return(mock_couch_db_schema)    
      mock_couch_db_schema.should_receive(:get_next_type_version_for).with('type').ordered.and_return(1)   
      mock_couch_db_schema.should_receive(:completed).with(delta2)
    
      deploy = Deploy.new(config)
      deploy.run
    end
  end
end
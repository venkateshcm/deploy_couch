require File.dirname(__FILE__) + '/../spec_helper'

describe Deploy, "load and execute deltas" do
  it "load and execute deltas in correct order" do
    config = get_couchdb_config
    delta = Delta.new('file_name','type','map function')
    delta2 = Delta.new('file_name2','type','map function')
    deltas_map = {1=>delta,10=>delta2}
    
    mock_delta_loader = mock(DeltaLoader)
    DeltaLoader.should_receive(:new).with("/somefolder/path/to/deltas").and_return(mock_delta_loader)
    mock_delta_loader.should_receive(:get_deltas).and_return(deltas_map)

    mock_repository = mock(Repository)
    Repository.should_receive(:new).with(config).and_return(mock_repository)

    mock_delta_processor = mock(DeltaProcessor)
    DeltaProcessor.should_receive(:new).with(config,delta,mock_repository).ordered.and_return(mock_delta_processor)    
    mock_delta_processor.should_receive(:apply)

    mock_delta_processor2 = mock(DeltaProcessor)
    DeltaProcessor.should_receive(:new).with(config,delta2,mock_repository).ordered.and_return(mock_delta_processor2)    
    mock_delta_processor2.should_receive(:apply)

    
    deploy = Deploy.new(config)
    deploy.run
  end
end
require File.dirname(__FILE__) + '/../spec_helper'

describe DeltaLoader, "load all delta" do

  it "should load all YAML files from the deltas folder" do
    
    map_function = "function map(doc) { doc.address = \"some address\"; return 'update'; }" 

    delta_loader = DeltaLoader.new(File.dirname(__FILE__)+'/deltas')
    deltas = delta_loader.get_deltas
    deltas.count.should == 4
    deltas[1].file_name.should == "1_add_address_to_customer.yml"
    deltas[1].type.should == "customer"
    deltas[1].map_function.should == map_function
  end
  
  it "should  raise an error when file is not in deltanumber_description format" do
    File.new(File.dirname(__FILE__)+'/deltas/invalid_delta_file.yml','w')
    begin
      delta_loader = DeltaLoader.new(File.dirname(__FILE__)+'/deltas')
      lambda { delta_loader.get_deltas }.should raise_error()
    ensure
      File.delete(File.dirname(__FILE__)+'/deltas/invalid_delta_file.yml')
    end    
  end
  
  it "should raise an error when two deltas have the same key" do
    File.new(File.dirname(__FILE__)+'/deltas/11_duplicate_key.yml','w')
    begin
      delta_loader = DeltaLoader.new(File.dirname(__FILE__)+'/deltas')
      lambda { delta_loader.get_deltas }.should raise_error()
    ensure
      File.delete(File.dirname(__FILE__)+'/deltas/11_duplicate_key.yml')
    end    
    
  end
  
  it "should raise an error when file content does not have both type and map_function" do
    File.new(File.dirname(__FILE__)+'/deltas/100_invalid_delta_file_content.yml','w')
    begin
      delta_loader = DeltaLoader.new(File.dirname(__FILE__)+'/deltas')
      lambda { delta_loader.get_deltas }.should raise_error()
    ensure
      File.delete(File.dirname(__FILE__)+'/deltas/100_invalid_delta_file_content.yml')
    end    
  end
  
  
end

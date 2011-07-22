require 'rubygems'
require 'rspec'
require File.dirname(__FILE__) + '/../lib/deploy_couch'


def get_couchdb_config
  CouchConfig.new({"hostname"=>"localhost","port"=>1234,"database"=>"db",'delta_path'=>"path/to/deltas","config_folder_path" => "/somefolder","doc_type_field"=>"type","type_version_field" => 'type_version' })
end

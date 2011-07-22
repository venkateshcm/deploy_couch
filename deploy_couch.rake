require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "deploy_couch"
    s.version   =   "0.0.1"
    s.author    =   "Venky/MLN"
    s.email     =   "venkatesh.swdev@gmail.com"
    s.summary   =   "dbDeploy for couchdb"
    s.files     =   FileList['lib/**/*.rb', 'spec/**/*'].to_a
    s.require_path  =   "lib"
    s.autorequire   =   "deploy_couch"
    s.test_files = Dir.glob('spec/**/*.rb')
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README"]
    s.add_dependency("dependency", ">= 0.x.x")
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end
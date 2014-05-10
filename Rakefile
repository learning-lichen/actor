require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec do |task|
  task.rspec_opts = %w(--color --format nested)
end

RDoc::Task.new :rdoc do |rdoc|
  rdoc.rdoc_files.include "lib/**/*.rb"
  rdoc.options << "--all"
end

task default: [:spec, :rdoc]
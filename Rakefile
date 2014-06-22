require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new {|t|
  # t.libs << 'lib'
  t.test_files = FileList['tests/**/*']
}

desc 'Run tests'
task :default => :test

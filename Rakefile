require 'rake/testtask'
require 'launchy' rescue nil

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

desc "Install to the default path (normally /etc/sv)"
task :install do
  require './lib/runit'
  Runit::Writer.new.write_all!
end

if defined?(Launchy)
  require 'tmpdir'
  require './lib/runit'
  desc "Install to a tempdir and open using Launchy appropriate for your platform, only available in development mode, or where launchy is installed"
  task :'dry-run' do
    Dir.mktmpdir.tap do |tmpdir|
      Runit::Writer.new(nil, tmpdir).write_all!
      Launchy.open("file://#{tmpdir}")
    end
  end
end

task :default => :test

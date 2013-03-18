require 'rake/testtask'
begin
  require 'launchy'
rescue LoadError
  warn "Launchy tasks not available"
end

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

desc "Link all files in /etc/sv to /etc/service"
task :symlink do
  "ls /etc/sv | sudo xargs -i ln -sf /etc/sv/{} /etc/service/{}".tap do |cmd|
    puts cmd
    `#{cmd}`
  end
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

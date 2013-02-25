require 'helper'

module Runit

  class WriterTestCase < TestCase

    def setup
      cfp     = File.expand_path("config/full.json", File.dirname(__FILE__))
      @writer = Writer.new(cfp)
    end

    def test_the_default_output_directory_is_etc_sv
      assert_equal Pathname.new("/etc/sv"), Writer.new.output_directory
    end

    def test_the_default_configuratiln_file_is_config_runit_dot_json
      cfp = File.expand_path("../config/runit.json", File.dirname(__FILE__))
      assert_equal cfp, Writer.new.configuration_file
    end

    def test_accessing_services
      assert_equal 1,             @writer.services.length
      assert_equal 'testservice', @writer.services.first.name
    end

    # This test is a bit weird, we're asserting as much on the structure
    # as on anyhting else, the files themselves are tested in the +Service+
    # tests.
    def test_outputting_all_services

      FakeFS do
        # Write everything to the filesystem
        @writer.write_all!
        # Ensure that we didn't end up with an empty
        # list of services
        assert @writer.services.any?
        @writer.services.each do |service|
          # Service Directory
          assert Dir.exists?  "/etc/sv/#{service.name}"
          assert File.exists? "/etc/sv/#{service.name}/run"
          #assert_equal service.run_file, File.read("/etc/sv/#{service.name}/run")
          # Service Logging Directory & Manifest
          assert Dir.exists?  "/etc/sv/#{service.name}/log"
          assert File.exists? "/etc/sv/#{service.name}/log/run"
          # Environmental Variable Directories
          assert Dir.exists?  "/etc/sv/#{service.name}/env/"
          assert File.exists? "/etc/sv/#{service.name}/env/RAILS_ENV"
          assert File.exists? "/etc/sv/#{service.name}/env/RACK_ENV"
          assert File.exists? "/etc/sv/#{service.name}/env/ANY_VAR"
          #assert_equal service.log_file, File.read("/etc/sv/#{service.name}/log/run")
          # Log Destination Directory
          assert Dir.exists? "/var/log/protonet/#{service.name}/"
        end
      end

    end

  end

end

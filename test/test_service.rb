require 'helper'

module Runit

  class ServiceTestCase < TestCase

    def setup
      config_dir       = Pathname.new(File.dirname(__FILE__)) + 'config'
      @concise         = Loader.new(config_dir + 'concise.json')
      @full            = Loader.new(config_dir + 'full.json')
      @concise_service = @concise.services.first
      @full_service    = @full.services.first
    end

    def test_concise_service_inherits_all_defaults
      assert_equal 209715200, @concise_service.options[:limitmemory]
    end

    def test_full_service_inherits_only_missing_properties_from_defaults
      assert_equal 419430400, @full_service.options[:limitmemory]
    end

    def test_concise_service_can_print_it_s_own_chpst_line
      assert_equal "-u test:test", @concise_service.chpst_args
    end

    def test_concise_service_can_print_it_s_own_run_file
      sample = <<-EOSCRIPT.unindent
        #!/bin/sh -e
        # No dependencies
        exec chpst -u test:test ./this/is/how/to start --me 2>&1
      EOSCRIPT
      assert_equal sample, @concise_service.run_file
    end

    def test_full_service_can_print_it_s_own_run_file
      sample = <<-EOSCRIPT.unindent
        #!/bin/sh -e
        sv check otherservice
        exec chpst -u service:override ./this/is/how/to start --me 2>&1
      EOSCRIPT
      assert_equal sample, @full_service.run_file
    end

  end

end

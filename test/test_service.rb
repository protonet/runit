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
      assert_equal "-u test:test -e /etc/sv/#{@concise_service.name}/env", @concise_service.chpst_args
    end

    def test_concise_env_options
      assert_equal({RAILS_ENV: 'development'}, @concise_service.env_vars)
    end

    def test_full_env_options_merges
      assert_equal({RAILS_ENV: 'production', RACK_ENV: 'testing', ANY_VAR: 'something'}, @full_service.env_vars)
    end

    def test_concise_service_can_print_it_s_own_run_file
      sample = <<-EOSCRIPT.unindent
        #!/bin/bash -e
        exec 2>&1
        # No dependencies
        # No change to pwd
        # No sources
        # http://smarden.org/runit/faq.html#user
        chmod 755      ./supervise
        chown protonet ./supervise/ok ./supervise/control ./supervise/status
        exec chpst -u test:test -e /etc/sv/testservice/env ./this/is/how/to start --me
      EOSCRIPT
      assert_equal sample, @concise_service.run_file
    end

    def test_full_service_can_print_it_s_own_run_file
      sample = <<-EOSCRIPT.unindent
        #!/bin/bash -e
        exec 2>&1
        sv check otherservice
        # No change to pwd
        source /etc/profile.d/rvm.sh
        source /etc/profile.d/protonet.sh
        # http://smarden.org/runit/faq.html#user
        chmod 755      ./supervise
        chown protonet ./supervise/ok ./supervise/control ./supervise/status
        exec chpst -u service:override -e /etc/sv/testservice/env ./this/is/how/to start --me
      EOSCRIPT
      assert_equal sample, @full_service.run_file
    end

    def test_service_can_create_it_s_own_log_file_definition
      sample = <<-EOSCRIPT.unindent
        #!/bin/sh -e
        exec svlogd -tt /var/log/protonet/testservice/
      EOSCRIPT
      assert_equal sample, @concise_service.log_file
      assert_equal sample, @full_service.log_file
    end

  end

end

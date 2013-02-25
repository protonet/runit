require 'helper'

module Runit
  class LoaderTestCase < TestCase

    def setup
      config_dir  = Pathname.new(File.dirname(__FILE__)) + 'config'
      @concise     = config_dir + 'concise.json'
      @full        = config_dir + 'full.json'
      @broken      = config_dir + 'broken.json'
      @nonexistent = config_dir + 'notthere.json'
    end

    def test_erring_when_the_file_doesn_t_exist
      assert_raises Runit::NonExistentConfiguration do
        Loader.new(@nonexistent)
      end
    end

    def test_erring_when_the_file_doesn_t_parse
      assert_raises Runit::UnparsableConfiguration do
        Loader.new(@broken)
      end
    end

    def test_loading_json_with_symbolized_keys
      assert Loader.new(@concise)[:defaults].is_a? Hash
    end

    def test_accessing_defaults_as_a_method_returning_a_hash
      assert Loader.new(@concise).defaults.is_a? Hash
    end

    def test_accessing_services_as_a_method_returning_a_hash_of_service_objects
      assert Loader.new(@concise).services.is_a? Array
    end

  end

end

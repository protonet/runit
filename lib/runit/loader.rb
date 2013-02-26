require 'forwardable'
require 'deep_merge'
require 'json'

module Runit

  class Loader

    attr_reader :hash

    extend Forwardable
    def_delegator :@hash, :[]

    def initialize(file_path)
      unless File.exists?(file_path)
        raise NonExistentConfiguration, "Configuration file #{file_path} does not exist."
      end
      @hash = JSON.parse(File.read(file_path), symbolize_names: true)
    rescue JSON::ParserError => e
      raise UnparsableConfiguration, e.message
    end

    def services
      @hash[:services].collect do |name, information|
        merged_information = information.deep_merge(@hash[:defaults])
        Service.new(name, merged_information)
      end
    end

    def defaults
      @hash[:defaults]
    end

  end

end

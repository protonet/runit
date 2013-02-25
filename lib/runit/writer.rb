require 'forwardable'
require 'fileutils'
require 'pathname'

module Runit
  class Writer
    extend Forwardable
    attr_reader :output_directory,
                :configuration_file
    def_delegator :@loader, :services
    def initialize(
        configuration_file = nil,
        output_directory   = '/etc/sv'
      )
      @output_directory   = Pathname.new(output_directory)
      @configuration_file = configuration_file || File.expand_path('./config/runit.json')
      @loader             = Loader.new(@configuration_file)
    end
    def write_all!
      services.each do |service|

        # Three directories to create:
        # * /etc/sv/{Service}/              # service_directory
        # * /etc/sv/{Service}/log/          # service_log_directory
        # * /var/log/protonet/{Service}/    # service.log_dir
        service_directory     = output_directory + service.name
        service_log_directory = service_directory + 'log'

        FileUtils.mkdir_p service_directory
        FileUtils.mkdir_p service_log_directory
        FileUtils.mkdir_p service.log_dir

        File.open service_directory + 'run', 'wb:utf-8' do |f|
          f.write service.run_file
        end

        File.open service_log_directory + 'run', 'wb:utf-8' do |f|
          f.write service.run_file
        end

      end
    end
  end
end

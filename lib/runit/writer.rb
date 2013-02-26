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
        service_env_directory = service_directory + 'env'

        FileUtils.mkdir_p service_directory
        FileUtils.mkdir_p service_log_directory
        FileUtils.mkdir_p service_env_directory if service.env_vars.any?
        FileUtils.mkdir_p service.log_dir

        # Write the actual run definition
        File.open service_directory + 'run', 'wb:utf-8' do |f|
          f.write service.run_file
        end
        File.chmod(0766, service_directory + 'run')

        # Write the log running service definition
        File.open service_log_directory + 'run', 'wb:utf-8' do |f|
          f.write service.log_file
        end
        File.chmod(0766, service_log_directory + 'run')

        # Write the env var files
        service.env_vars.each_pair do |variable, value|
          File.open service_env_directory + variable.to_s, 'wb:utf-8' do |f|
            f.write value
          end
        end

      end
    end
  end
end

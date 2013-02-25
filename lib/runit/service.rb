module Runit
  class Service

    ARG_OPT_MAP = {
      :setuidgid => '-u',
    }

    attr_reader :name, :properties
    def initialize(name, properties)
      @name       = name
      @properties = properties
    end

    def chpst_args
      ARG_OPT_MAP.collect do |key,switch|
        if options.has_key? key
          [switch, options.fetch(key)].join(' ')
        end
      end.join(' ')
    end

    def dependency_line
      "sv check #{dependencies.join(' ')}"
    end

    def dependencies
      properties[:depends] || []
    end

    def start_command
      commands[:start]
    end

    def commands
      properties[:commands] || {}
    end

    def options
      properties[:options] || {}
    end

    def run_file
      <<-EOHEREDOC.unindent
        #!/bin/sh -e
        #{dependencies.any? ? dependency_line : "# No dependencies"}
        exec chpst #{chpst_args} #{start_command} 2>&1
      EOHEREDOC
    end

  end
end

module Runit
  class Service

    ARG_OPT_MAP = {
      :setuidgid => '-u',
    }

    attr_reader :name, :properties
    def initialize(name, properties)
      @name       = name.to_s
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

    # man (1) svlogd
    # -tt timestamp. Prefix each selected line with a human
    # readable, sortable UTC timestamp of the form
    # YYYY-MM-DD_HH:MM:SS.xxxxx when writing to log or to
    # standard error.
    def log_file
      <<-EOHEREDOC.unindent
        #!/bin/sh -e
        exec svlogd -tt #{log_dir}
      EOHEREDOC
    end

    def log_dir
      "/var/log/protonet/#{name}/"
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
require 'unindent'

module Runit
  class Service

    ARG_OPT_MAP = {
      :setuidgid => '-u',
      #:root      => '-/'
    }

    attr_reader :name, :properties
    def initialize(name, properties)
      @name       = name.to_s
      @properties = properties
    end

    def chpst_args
      args = ARG_OPT_MAP.collect do |key,switch|
        if options.has_key? key
          [switch, options.fetch(key)].join(' ')
        end
      end
      args.push(*['-e', "/etc/sv/#{name}/env"]) if env_vars.any?
      args.join(' ')
    end

    def dependency_line
      "sv check #{dependencies.join(' ')}"
    end

    def dependencies
      properties[:depends] || []
    end

    def sources
      properties[:sources] || []
    end

    def sources_lines
      sources.collect do |source|
        ". #{source}".tap do |s|
          s.prepend(" "*8) unless sources.first == source
        end
      end.join("\n")
    end

    def env_vars
      Hash.new.tap do |vars|
        properties[:env].collect do |variable, value|
          vars[variable.upcase.to_sym] = value
        end
      end
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

    def chdir_line
      "cd #{options[:chdir]}" if options[:chdir]
    end

    def run_file
      <<-EOHEREDOC.unindent
        #!/bin/sh -e
        exec 2>&1
        #{dependencies.any? ? dependency_line : "# No dependencies"}
        #{sources.any?      ? sources_lines   : "# No sources"     }
        #{chdir_line || "# No change to pwd"                       }
        # http://smarden.org/runit/faq.html#user
        chmod 755      ./supervise
        chown protonet ./supervise/ok ./supervise/control ./supervise/status
        exec chpst #{chpst_args} #{start_command}
      EOHEREDOC
    end

  end
end

require './lib/runit/loader'

module Runit

  StandardError            = Class.new(StandardError)
  NonExistentConfiguration = Class.new(Runit::StandardError)
  UnparsableConfiguration  = Class.new(Runit::StandardError)

end

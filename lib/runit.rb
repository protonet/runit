require './lib/runit/loader'
require './lib/runit/service'
require './lib/runit/writer'

module Runit

  StandardError            = Class.new(StandardError)
  NonExistentConfiguration = Class.new(Runit::StandardError)
  UnparsableConfiguration  = Class.new(Runit::StandardError)

end

require 'bundler'
Bundler.require(:default, :test)

# Stdlib
require 'pathname'

# Pull the app in
require 'runit'

module Runit

  TestCase = ::MiniTest::Unit::TestCase

end

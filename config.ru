require './app'

run Rack::URLMap.new('/' => App)
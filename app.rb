require 'sinatra'
require 'rubygems'
Dir[File.dirname(__FILE__) + '/modules/*.rb'].each {|file| require file}


class App < Sinatra::Base

	get '/' do
		# content_type 'html'
		# "Hello Sinatra"
		@number = Calculation.random_number
		@stop_words = Tokenizer.stop_words
		@tokens = Tokenizer.remove_stop_words('document')
		erb :index
	end
end
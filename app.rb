require 'sinatra'
require 'rubygems'
require 'pry'

Dir[File.dirname(__FILE__) + '/modules/*.rb'].each {|file| require file}

class App < Sinatra::Base

	get '/' do
		@movie_names = Tokenizer.movie_names
		erb :index
	end

	post '/recommend' do
		@user_choice = @params[:movie_name]
		@recommended_movies = [Tokenizer.recommend(@user_choice)]
	end

	get '/recommend' do
		@user_choice = @params[:movie_name]
		@recommended_movies = Tokenizer.recommend(@user_choice) || []
		
		erb :similar_movies
	end
end
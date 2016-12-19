This project is about recommending similar movies to a user based on his selection. It uses tf-idf calculation between the "descriptions" of the movies and uses "Cosine Similarity" calculation to find the closest match.

How to use this project?

1. This project is available online in heroku.
	https://movierecomm.herokuapp.com/

	a. Select a movie from the given list
	b. The top 10 movies that are similar to the selected movie will be displayed. The similarity is 	based on the cosine similarity among the descriptions on the movies.

2. To Use this project in local machine

	a. Fork the project from: https://github.com/amitshrestha/MovieRecommendation
	b. Install required dependencies (Ruby and Sinatra)
	c. Go to the project directory in local machine
	d. Type following commands:(for mac OSX)
		- bundle Install     (installs dependencies)
		- rackup             (starts server)

Important Files:
1. tokenizer.rb:
	- All the tf-idf and cosine similarity calculation happens in this file.

2. movie_datalist.csv:
	- A csv file that contains all the information about the 50 movies

3. simple_stop_wordlist.txt:
	= A simple txt file that contains simple stop words taken from online.

How does this project recommends movie?
1. Given a movie selected by a user (M)
2. Takes the description of M.
3. Removes stop words from description of M.(query tokens)
4. Removes stop words from all other movies description. (other movie's tokens)
5. Calculates tf-idf for query tokens and other movies tokens.
6. Finds Cosine similarity of query movie with each of the other movies.
7. Displays top 10 movies with highest cosine similarity value.



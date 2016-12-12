require 'csv'
module Tokenizer
  extend self

  def self.movie_names
    movies = []
    CSV.foreach("movie_datalist.csv", :headers => true) do |row|
      movies << row['Title']
    end
    return movies.sort
  end


  #movie_map_hash is the hash with id as key and tokens as value
  #movie_map_hash is used at the final display after calculating all cosine similarity
  def self.movie_map_hash
    movie_hash = {}
    CSV.foreach("movie_datalist.csv", :headers => true) do |row|
      movie_description = row['Description']
      id = row['ID']
      tokens = self.remove_stop_words(movie_description)
      movie_hash[id] = tokens
    end
    movie_hash
  end


  def self.tokenize_document
    keywords_in_each_document = []
    CSV.foreach("movie_datalist.csv", :headers => true) do |row|
      movie_description = row['Description']
      tokens = self.remove_stop_words(movie_description)
      keywords_in_each_document << tokens
    end
  	return keywords_in_each_document
  end

  def self.tokenize_query(query)
    data = File.read('movie_datalist.csv')
    csv = CSV.parse(data, :headers => true)
    selected_movie = csv.find {|row| row['Title'] == query.to_s}
    tokens = self.remove_stop_words(selected_movie['Description'].to_s)
    tokens
  end

  def merge_description_and_title

  end

  def self.stop_words(filename = "simple_stop_wordlist")
  	@stop_words = []
  	File.open(filename + '.txt') do |f|
  		f.each_line do |line|
    		@stop_words << line.strip
  		end
  	end
  	@stop_words.flatten
  end

  #tokenize (by removing stop words)
  def self.remove_stop_words(document)
  	# sample_text = "This spectacular epic re-creates the ill-fated maiden voyage of the White Star Line's $7.5 million R.M.S Titanic and the tragic sea disaster of April 15, 1912. Running over three hours and made with the combined contributions of two major studios (20th Century-Fox, Paramount) at a cost of more than $200 million, Titanic ranked as the most expensive film in Hollywood history at the time of its release, and became the most successful. Writer-director James Cameron employed state-of-the-art digital special effects for this production, realized on a monumental scale and spanning eight decades. Inspired by the"
  	splitted_document = document.strip.split(' ')
  	@tokens = (splitted_document - self.stop_words('simple_stop_wordlist')).first(100) rescue []
  end

  def self.total_number_of_documents
    file = CSV.open("movie_datalist.csv")
    file.readlines.size
  end

  def calculate_tf(tokens)
    term_frequency = Hash.new {|h, k| h[k] = 0 }
    normalized_term_freq = Hash.new {|h, k| h[k] = 0 }
    if !(tokens.empty?)
      tokens.each { |word| term_frequency[word] += 1 }

      #maximum frequency present in the document
      normalization_factor = term_frequency.values.uniq.max
      # Normalize the count
      term_frequency.each_key do |term|
        term_frequency[term] = term_frequency[term].fdiv(normalization_factor)
      end
      # normalized_term_freq = term_frequency/tokens.size

      term_frequency
    end

    term_frequency
  end

  def calculate_idf(tokens)
    inverse_document_freq = Hash.new {|h, k| h[k] = 0 }

    #all tokens (uniq for each document)
    tokens = tokenize_document

    tokens.each do |term|
      inverse_document_freq[term] += 1
    end

    inverse_document_freq.each_pair do |term, count|
      inverse_document_freq[term] =  Math.log2(self.total_number_of_documents/count)
    end

    inverse_document_freq

  end

  def calculate_tf_idf(tokenized_query)
    normalized_term_freq = calculate_tf(tokenized_query)
    inverse_document_freq = calculate_idf(tokenized_query)

    #final vector with tf*idf
    idf_value = inverse_document_freq[tokenized_query]
    normalized_term_freq.each do |key, value|
      normalized_term_freq[key] = (value * idf_value) || 0.00
    end
    
    normalized_term_freq
  end

  #here documents are all movies except the query.
  def compute_tf_idf_and_cosine_similarity(documents, tf_idf_weight_for_query)
    movie_similarity_hash = {}
    documents.each do |document|
      tf_idf_for_document = calculate_tf_idf(document)
      sim_value = calculate_cosine_similarity(tf_idf_for_document, tf_idf_weight_for_query)

      movie_similarity_hash[document] = sim_value
    end
    movie_similarity_hash
  end

  def similar_movie_hash(similarity_score)

    final_similarity_hash ={}
    #get the id of the movie
    movie_hash = movie_map_hash
    values = movie_hash.values
    similarity_score.each do |tokens, score|
      if(values.include?(tokens))
        # key is the id of the movie
        key = movie_hash.key(tokens) || 0
        final_similarity_hash[key] = score
      end
    end
    final_similarity_hash
  end

  def calculate_cosine_similarity(tf_idf_for_document, tf_idf_weight_for_query)
    numerator_sum = 0
    tf_idf_for_document.each do |key, value_in_document|
      value_in_query = tf_idf_weight_for_query[key] || 0
      numerator_sum = numerator_sum + value_in_document * value_in_query
    end

    magnitude_of_document_vector = tf_idf_for_document.values.flatten.inject(0) {|sum, value| sum + value * value}
    magnitude_of_query_vector = tf_idf_weight_for_query.values.flatten.inject(0) {|sum, value| sum + value * value}
    denominator = magnitude_of_document_vector * magnitude_of_query_vector
    similarity_value = numerator_sum.fdiv(denominator)

    similarity_value
  end

  #user choice is the query( the movie selected by user)
  def recommend(user_choice)
    # query = get_user_choice_description(user_choice)
    tokenized_query = tokenize_query(user_choice)
    documents = tokenize_document - [tokenized_query]
    tf_idf_weight_for_query = calculate_tf_idf(tokenized_query)

    similarity_hash = compute_tf_idf_and_cosine_similarity(documents, tf_idf_weight_for_query)
    title_and_similarity_hash = similar_movie_hash(similarity_hash)

    #sort the title_and_similarity_hash in descending value by value
    sorted_recommended_movies = Hash[title_and_similarity_hash.sort_by{|k, v| v}.reverse] || {}

    get_top_movies(sorted_recommended_movies)
  end

  def get_top_movies(sorted_recommend_movies)
    Hash[sorted_recommend_movies.sort_by { |k,v| -v }[0..5]]
  end

end
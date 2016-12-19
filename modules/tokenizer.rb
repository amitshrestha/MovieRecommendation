require 'csv'
module Tokenizer
  extend self

  def self.movie_names
    movies = []
    CSV.foreach("movie_datalist.csv", :headers => true) do |row|
      movies << row['Title']
    end
    return movies.compact.sort
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

      term_frequency
    end

    term_frequency
  end

  def calculate_idf
    inverse_document_freq = Hash.new {|h, k| h[k] = 0 }

    #all tokens (uniq for each document)
    all_tokens = tokenize_document
    unique_word_in_each_document = all_tokens.map(&:uniq).flatten
    
    unique_word_in_each_document.each do |term|
      inverse_document_freq[term] += 1
    end

    number_of_documents = Math.log2(self.total_number_of_documents)
    inverse_document_freq.each_pair do |term, count|
      inverse_document_freq[term] =  number_of_documents - Math.log2(count)
    end

    inverse_document_freq

  end

  def calculate_tf_idf(tokenized_query)
    normalized_term_freq = calculate_tf(tokenized_query)
    inverse_document_freq = calculate_idf

    #final vector with tf*idf
    normalized_term_freq.each do |key, value|
      normalized_term_freq[key] = (value * inverse_document_freq[key]) || 0.00
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
    movie_hash = movie_map_hash
    values = movie_hash.values
    similarity_score.each do |tokens, score|
      if(values.include?(tokens))
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
    denominator = Math.sqrt(magnitude_of_document_vector) * Math.sqrt(magnitude_of_query_vector)
    similarity_value = numerator_sum.fdiv(denominator) rescue 0.0

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

    top_movies = get_top_movies(sorted_recommended_movies)

    get_top_movie_details(top_movies)
  end

  def get_top_movies(sorted_recommend_movies)
    Hash[sorted_recommend_movies.sort_by { |k,v| -v }[0..9]]
  end

  def self.get_top_movie_details(top_movies)
    movie_detail = []
    movie_ids = top_movies.keys.flatten

    data = File.read('movie_datalist.csv')
    csv = CSV.parse(data, :headers => true)
    movie_ids.each do |m_id|
      row = csv.find {|row| row['ID'] == m_id}
      details = {'Title'=> row['Title'], 'Genre'=> row['Genre'], 'Director'=> row['Director'], 'Studio'=> row['Studio'], 'Release year'=> row['Release year'],'Rating'=> row['Rating'], 'URL'=> row['URL'], 'Description'=> row['Description'], 'Image_url'=> row['Image_url']}
      movie_detail.push([m_id, details])
    end
    movie_detail
  end

end
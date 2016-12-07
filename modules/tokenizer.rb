module Tokenizer
  extend self

  def tokenize_document
    keywords_in_each_document = []
    CSV.open("movie_datalist.csv") do |row|
      movie_description = row['description']
      tokens = self.remove_stop_words(movie_description)
      keywords_in_each_document << tokens
    end
  	return 5000
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
  	sample_text = "This spectacular epic re-creates the ill-fated maiden voyage of the White Star Line's $7.5 million R.M.S Titanic and the tragic sea disaster of April 15, 1912. Running over three hours and made with the combined contributions of two major studios (20th Century-Fox, Paramount) at a cost of more than $200 million, Titanic ranked as the most expensive film in Hollywood history at the time of its release, and became the most successful. Writer-director James Cameron employed state-of-the-art digital special effects for this production, realized on a monumental scale and spanning eight decades. Inspired by the"
  	document = sample_text.strip.split(' ')
  	@tokens = (document - self.stop_words('simple_stop_wordlist')).first(100) rescue []
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
      # Normalize the count
      normalized_term_freq = term_frequency/tokens.size

      normalized_term_freq
    end

    normalized_term_freq
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

  def calculate_cosine_similarity
  end

  def recommend
  end
end
module Tokenizer
  extend self

  def tokenize
  	return 5000
  end

  def merge_description_and_title

  end

  def self.stop_words(filename = "simple_stop_wordlist")
  	@stop_words = []
  	File.open(filename + '.txt') do |f|
  		f.lines.each do |line|
    		@stop_words << line.strip
  		end
  	end
  	@stop_words.flatten
  end

  def self.remove_stop_words(document)
  	sample_text = "This spectacular epic re-creates the ill-fated maiden voyage of the White Star Line's $7.5 million R.M.S Titanic and the tragic sea disaster of April 15, 1912. Running over three hours and made with the combined contributions of two major studios (20th Century-Fox, Paramount) at a cost of more than $200 million, Titanic ranked as the most expensive film in Hollywood history at the time of its release, and became the most successful. Writer-director James Cameron employed state-of-the-art digital special effects for this production, realized on a monumental scale and spanning eight decades. Inspired by the"
  	document = sample_text.strip.split(' ')
  	@tokens = (document - self.stop_words('simple_stop_wordlist')).first(100) rescue []
  end
end
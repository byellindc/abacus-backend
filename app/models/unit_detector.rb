class UnitDetector
  PREFIXES = %w($ € £)
  SUFFIXES = %w(s m h w y MB GB)

  def initialize(input)
    @input = input
    @units = {}
  end

  def tokens
    @input.split(' ')
  end

  # def token_map
  #   self.tokens.each { |token| yield(token) }
  # end

  def process_tokens
    prefix_regex = /^(?<prefix>#{PREFIXES.join('|')})(?<num>-?[\d.]+)$/
    suffix_regex = /^(?<num>-?[\d.]+\s?)(?<suffix>#{SUFFIXES.join('|')})$/

    self.tokens.each do |token|
      
    end
  end
end
class ContentReplacer
  attr_accessor :replacements, :case_sensitive

  def initialize(replacements)
    @replacements = replacements.with_indifferent_access
    @case_sensitive = true
    puts "ContentReplacer: #{replacements}"
  end

  def add(key, val)
    @replacements[key] = val
  end

  def remove(key)
    @replacements.delete(key)
  end

  def apply(text)
    new_text = text
    @replacements.each do |k,v| 
      replace!(new_text, k, v)
    end
    return new_text
  end

  def self.apply(text, replacements)
    replacer = ContentReplacer.new(replacements)
    return replace.run(text)
  end

  private

  def value(key)
    @replacements[key]
  end

  def replacement_regex(key)
    opts = @case_sensitive ? nil : Regexp::IGNORECASE
    Regexp.new("\\b#{key.to_s}\\b", opts)
  end

  def replace!(text, key, val = nil)
    val ||= @replacements[key]
    return if val.nil? || val.blank?
    gsub!(text, key, val)
  end

  def gsub!(text, key, val)
    regex = replacement_regex(key)
    text.gsub!(regex, val)
  end
end
class LineProcessor
  attr_reader :input, :expression, :name, :mode
  MODES = %s(calculation comment invalid)

  def initialize(line, store = {})
    @line = line
    @input = line.input
    @expression = @input

    @mode = :calculation
    @errors = []
    @store = store

    process
  end

  def self.process!(line, store = nil)
    processor = LineProcessor.new(line, store)
    processor.apply!
  end

  def attributes
    {
      name: self.name,
      input: self.input,
      expression: self.expression,
      mode: self.mode
    }
  end

  def process
    detect_comments
    translate_word_operators
    standardize_spacing
    expand_variables
    parse_percentage_expression
    reformat_math_functions
    convert_units
    
    trim_whitespace
    # validate
  end

  def apply!
    @line.expression = self.expression
    @line.name = self.name
    @line.mode = self.mode
    return @line
  end

  # def has_variable?
  #   return !!@name
  # end

  private

  def standardize_spacing
  #   operators = %w(* / + -)
  #   operator_regex = /[*\/+-]/

  #   @expression.gsub(/([^\s\b])([*\/+-])/, '$1')
    
  #   tokens = []
  #   current = nil
    
  #   @expression.split('').each do |c|
  #     if c =~ /\s/
  #       tokens << current if current
  #       current = nil
  #     elsif 
  #     if operators.include? c
  #   end
  end
  
  # matches `[PERCENTAGE] of [NUM]`
  # and `[PERCENTAGE] (off|on) [NUM]`
  def parse_percentage_expression
    regex = /(?<percentage>-?[\d.]+)% (?<operator>(off?|on)) (?<expr>.*$)/
    match = @expression.match(regex)

    if match
      operator = match.named_captures["operator"]
      percentage = match.named_captures["percentage"]
      expr = match.named_captures["expr"]

      percentage_expr = "#{expr} * #{percentage.to_f/100}"

      case operator
      when 'of'
        @expression = percentage_expr
      when 'off'
        @expression = "#{expr} - (#{percentage_expr})"
      when 'on'
        @expression = "#{expr} + (#{percentage_expr})"
      end
    end
  end
    
  # reformat any mathmatical functions
  # from lowercase to upper
  # e.g. avg(1,2) -> AVG(1,2)
  def reformat_math_functions
    funcs = %w(min max sum avg count round rounddown roundup sin cos tan)
    regex = /\b(?<func>#{funcs}.join('|'))\((?<expr>[^()]+)\)/
    match = @expression.match(regex)

    if match
      func = match.named_captures["func"]
      expr = match.named_captures["expr"]
      @expression = "#{func.upcase}(#{expr})"
    end
  end

  def translate_word_operators
  end

  def convert_units
  end

  # comments resemble c-style, single-line statements `//[...]`
  # when commented out, the processed expression will be blank 
  def detect_comments
    if @input =~ %r{^\s*[/]{2}}
      @mode = :comment
      @expression = ''
    end
  end

  def valid_var_name?(name)
    name =~ /^[\w]+$/
  end

  def get_var(name)
    @store[name.downcase]
  end

  def is_var?(name)
    valid_var_name?(name) && !!get_var(name)
  end

  def invalid_var?(name)
    valid_var_name?(name) && !is_var?(name)
  end

  # currently variables are only expanded when 
  # surrounded by whitespace or ends of line
  def expand_variables
    # var_regex = /^[\w]+$/
    # var_regex = /([\s\b])[\w]+([\s\b])/
    @expression = @expression.split(' ').map do |token|
      if !valid_var_name?(token)
        return token
      elsif is_var?(token)
        return get_var(token)
      else
        @mode = :invalid
        @errors << {message: "invalid variable name", info: token}
        return token
      end
    end.join(' ')
  end

  # remove leading and trailing whitespace from expression
  def trim_whitespace
    @expression.strip!
  end

  # if non-blank expression is invalid
  # then mark mode as :invalid
  def validate
    # @expression && !@expression.blank?
    if !@expression || @expression.blank?
      return
    elsif !Calculator.valid?(@expression)
      @expression = nil
      @mode = :invalid
    end
  end
end
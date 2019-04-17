require 'ruby-units'
require 'dentaku'

class LineProcessor
  attr_reader :name, :mode
  attr_reader :in_unit, :out_unit
  attr_reader :input, :expression, :result
  MODES = %s(calculation conversion comment invalid blank)

  def initialize(line, store = {})
    @line = line
    @input = line.input
    @expression = @input

    @mode = :calculation
    @errors = []
    @store = store

    process
  end

  def self.process!(line, store = {})
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
    detect_blank
    detect_comments
    
    translate_word_operators
    translate_word_amounts
    
    standardize_spacing
    
    # process_units
    process_variable_assignment
    # expand_variables

    parse_percentage_expression
    reformat_math_functions

    parse_conversions
    convert_units
    
    trim_whitespace
    # validate
  end

  def apply!
    @line.expression = self.expression
    @line.result = self.result if self.result

    @line.name = self.name
    @line.mode = self.mode

    @line.in_unit = self.in_unit
    @line.out_unit = self.out_unit

    return @line
  end

  # def has_variable?
  #   return !!@name
  # end

  def tokens
    @expression.split(' ')
  end

  def tokens=(tokens)
    @expression = tokens.join(' ')
  end

  def map_tokens
    self.tokens.map { |token| yield(token) }
  end

  def match(regex)
    @expression.match(regex)
  end

  private

  def standardize_spacing
    operators = %w(* / + -)
    operator_regex = /[*\/+-]/

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
    # match = @expression.match(regex)

    if self.match(regex)
      func = match.named_captures["func"]
      expr = match.named_captures["expr"]
      @expression = "#{func.upcase}(#{expr})"
    end
  end

  def translate_word_operators
    # word_operators = {
    #   # "(?<amount>(an? |one )?(half|third|quarter) (of|off|on)": "50% of"
    # }
  end

  def translate_word_amounts
    amounts = {
      "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, 
      "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10, 
      "quarter": "25%", "half": "50%"
    }
    
    self.tokens = self.map_tokens do |token|
      amounts[token] || token
    end

    # @expression = @expression.split(' ').map do |token|
    #   amounts[token] || token
    # end
  end

  def parse_conversions
    # regex = /(?<operator>\s+as|\s+to|\s+in|\s*>|\s*:)\s+(?<to>.*)/
    regex = /(\s+as|\s+to|\s+in|\s*>|\s*:)\s+/
    parts = @expression.split(regex)
  
    # puts "parts"
    # puts parts

    if parts.length >= 3
      @mode = :conversion

      in_expr = parts[0]
      out_expr = parts[2]

      begin
        in_parsed = Unit.parse_into_numbers_and_units(in_expr)
        out_parsed = Unit.parse_into_numbers_and_units(out_expr)

        @in_unit = in_parsed[1]
        @out_unit = out_parsed[1]
        @expression = in_parsed[0].to_s

        conversion = Unit.new(in_expr).convert_to(@out_unit)
        @result = Unit.parse_into_numbers_and_units(conversion.to_s)[0]
      rescue ArgumentError => err
      end
    end
  end

  def process_units
  end

  def convert_units
  end

  def detect_blank
    if @input.blank?
      @mode = :blank
      @expression = ''
    end
  end

  # comments resemble c-style, single-line statements `//[...]`
  # when commented out, the processed expression will be blank 
  def detect_comments
    if @input =~ %r{^\s*[/]{2}}
      @mode = :comment
      @expression = ''
    end
  end

  # if input matches `[VAR] = [EXPRESSION]`
  # extract variable name and expression
  def process_variable_assignment
    regex = %r{(?<name>\w+)( = )(?<expression>.*$)}
    match = @input.match(regex)

    if match
      @name = match.named_captures["name"]
      @expression = match.named_captures["expression"]
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
    # self.tokens = self

    # var_regex = /^[\w]+$/
    # var_regex = /([\s\b])[\w]+([\s\b])/

    # @expression = @expression.split(' ').map do |token|
    #   if !valid_var_name?(token)
    #     return token
    #   elsif is_var?(token)
    #     return get_var(token)
    #   else
    #     @mode = :invalid
    #     @errors << {message: "invalid variable name", info: token}
    #     return token
    #   end
    # end.join(' ')
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
class LineProcessor
  attr_reader :input, :expression, :name, :mode
  MODES = %s(calculation comment invalid)

  def initialize(line, store = {})
    @line = line
    @input = line.input
    @expression = @input
    @mode = :calculation
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

  def has_variable?
    return !!@name
  end

  private

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
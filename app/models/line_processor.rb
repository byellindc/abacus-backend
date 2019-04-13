class LineProcessor
  attr_reader :input, :expression, :name, :mode
  MODES = %s(calculation comment invalid)

  def initialize(input)
    @input = input
    @expression = input
    @mode = :calculation
    process
  end

  def process
    process_comments
    process_variable
    process_word_operators
    process_percentage_expression
    process_unit_conversions
    process_math_functions
    
    trim_whitespace
    validate
  end

  # def expression
  #   @expression if 
  # end

  def has_variable?
    return !!@name
  end

  private

  # if input matches `[VAR] = [EXPRESSION]`
  # extract variable name and expression
  def process_variable
    regex = %r{(?<name>\w+)( = )(?<expression>.*$)}
    match = @expression.match(regex)

    if match
      @name = match.named_captures["name"]
      @expression = match.named_captures["expression"]
    end
  end

  # matches `[PERCENTAGE] of [NUM]`
  # and `[PERCENTAGE] (off|on) [NUM]`
  def process_percentage_expression
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
  def process_math_functions
    funcs = %w(min max sum avg count round rounddown roundup sin cos tan)
    regex = /\b(?<func>#{funcs}.join('|'))\((?<expr>[^()]+)\)/
    match = @expression.match(regex)

    if match
      func = match.named_captures["func"]
      expr = match.named_captures["expr"]
      @expression = "#{func.upcase}(#{expr})"
    end
  end

  def process_word_operators
  end

  def process_unit_conversions
  end

  # comments resemble c-style, single-line statements `//[...]`
  # when commented out, the processed expression will be blank 
  def process_comments
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
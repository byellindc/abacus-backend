class LineProcessor
  attr_reader :input, :name, :expression, :mode

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
  end

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
    regex = /(?<percentage>-?[\d.]+)% (?<operator>(off?|on)) (?<num>-?[\d.]+)/
    match = @expression.match(regex)

    if match
      operator = match.named_captures["operator"]
      percentage = match.named_captures["percentage"]
      num = match.named_captures["num"]

      percentage_expr = "#{num} * #{percentage.to_f/100}"

      case operator
      when 'of'
        @expression = percentage_expr
      when 'off'
        @expression = "#{num} - (#{percentage_expr})"
      when 'on'
        @expression = "#{num} + (#{percentage_expr})"
      end
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
end
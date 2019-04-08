class LineProcessor
  attr_reader :input, :name, :expression

  def initialize(input)
    @input = input
    @expression = input
    process
  end

  def process
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

  def process_percentage_expression
  end

  def process_word_operators
  end

  def process_unit_conversions
  end

  def process_comments
  end
end
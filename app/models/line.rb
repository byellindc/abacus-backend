require_relative '../helpers/numeric_helper'

class Line
  attr_reader :document_id, :index
  attr_accessor :result, :name, :mode
  attr_accessor :input, :expression, :name
  alias :read_attribute_for_serialization :send

  MODES = %i(calculation comment invalid) 

  def initialize(document:, input: nil, index: nil)
    @document_id = document.id
    @input = input
    @index = index
    process
  end

  def to_json
    puts "to_json: #{self}"
    {
      document_id: self.document_id,
      input: self.input,
      expression: self.expression,
      mode: self.mode,
      name: self.name,
      result: self.result,
      result_formatted: self.result_formatted
    }
  end

  def from_json(json)
    self.input = json['input']
    process
    self
  end

  def result_formatted
    simplify_number(result)
  end

  def line_num
    self.index ? self.index + 1 : 1
  end

  def is_comment?
    self.mode.to_sym == :comment
  end

  def is_calculation?
    self.mode.to_sym == :calculation
  end

  def is_invalid?
    return true if self.mode.to_sym == :invalid
    self.is_calculation? && !self.has_result?
  end

  def has_result?
    self.result.is_a? Numeric
  end

  def has_expression?
    !!self.expression && !self.expression.blank?
  end

  def name
    @name || default_name
  end

  # def name=(name)
  #   @name = name.downcase
  # end

  # if a line does not have explicit 
  # variable assignment (`[VAR] = ...`)
  # the default name is `line[NUM]`
  def default_name
    return "line#{line_num}"
  end

  private

  def process
    processor = LineProcessor.new(self)
    @name = processor.name
    @expression = processor.expression
    @mode = processor.mode
  end

  def simplify_number(num)
    if !num.is_a? Numeric
      return num
    elsif num == num.to_i
      return num.to_i
    else
      return num.to_f
    end
  end
end
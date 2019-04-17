require_relative '../helpers/numeric_helper'

class Line
  attr_reader :document_id, :index
  attr_accessor :input, :expression
  attr_accessor :result, :name, :mode, :errors
  attr_accessor :in_unit, :out_unit, :prefix
  alias :read_attribute_for_serialization :send

  MODES = %i(calculation comment invalid) 

  def initialize(document: nil, input: nil, index: nil)
    @document_id = document.id if document
    @input = input
    @index = index
    @errors = []
    # process
  end
  
  def to_json
    {
      document_id: self.document_id,
      input: self.input,
      expression: self.expression,
      mode: self.mode,
      name: self.name,
      result: self.result,
      result_formatted: self.result_formatted,
      in_unit: self.in_unit,
      out_unit: self.out_unit,
      prefix: self.prefix,
    }
  end

  def from_json(json)
    self.input = json['input']
    process
    self
  end

  # simplifies result value
  # and appends/prepends unit to expression
  # if out_unit is present
  def result_formatted
    formatted = simplify_number(self.result)

    if self.prefix
      formatted = '%.2f' % self.result
      return "#{prefix}#{formatted}"
    elsif self.out_unit
      return "#{formatted} #{out_unit}"
    else
      return formatted
    end
  end

  # appends/prepends unit to expression
  # if in_unit is present
  def expression_formatted
    if self.in_unit
      return "#{self.expression} #{self.in_unit}"
    else
      return self.expression
    end
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

  def is_conversion?
    self.mode.to_sym == :conversion
  end

  def is_invalid?
    (self.is_calculation? || self.is_conversion?) && !self.has_result?
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

  # if a line does not have explicit 
  # variable assignment (`[VAR] = ...`)
  # the default name is `line[NUM]`
  def default_name
    return "line#{line_num}"
  end

  def process
    processor = LineProcessor.new(self)

    @name = processor.name
    @expression = processor.expression
    
    @in_unit = processor.in_unit
    @out_unit = processor.out_unit
    @prefix = processor.prefix
    
    @mode = processor.mode
    @result = processor.result if processor.result

    return self
  end

  private

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
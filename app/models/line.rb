class Line < ApplicationRecord
  belongs_to :document
  before_save :reprocess

  def reprocess
    if input_changed?
      process_expression
      evaluate_result
    end
  end

  def result
    result_formatted
  end

  def write(text)
    self.update(input: text)
  end

  # def name
  #   self.read_attribute(:name) || "line#{line_num}"
  # end

  # line's index within document
  def index
    self.document.lines.index(self)
  end

  def line_num
    self.index ? self.index + 1 : 0
  end

  private
 
  def evaluate_result
    self.result = document.eval(self.expression)
  end
 
  # uses LineProcessor to convert raw input
  # into a pure mathmatical expression
  def process_expression
    processor = LineProcessor.new(self.input)
    self.name = processor.name
    self.expression = processor.expression
    save_variable
  end

  def save_variable
    if self.name 
      self.document.save_variable(self.name, self)
    end
  end

  # recast result if it can be expressed as an integer
  # e.g. 1.0 => 1, 1.1 => 1.1
  def result_formatted
    result_val = self.read_attribute(:result)
    result_val == result_val.to_i ? result_val.to_i : result_val.to_f
  end
end

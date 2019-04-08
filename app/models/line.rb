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

  private
 
  def evaluate_result
    self.result = document.eval(expression)
  end

  # def reload_processed
  #   self.processed = process_input
  # end

  # def proccess_result
  #   self.result = evaluate_result
  # end
 
  # uses LineProcessor to convert raw input
  # into a pure mathmatical expression
  def process_expression
    processor = LineProcessor.new(input, line_num)
    self.name = processor.name
    self.expression = processor.expression
  end

  # recast result if it can be expressed as an integer
  # e.g. 1.0 => 1, 1.1 => 1.1
  def result_formatted
    result_val = self.read_attribute(:result)
    result_val == result_val.to_i ? result_val.to_i : result_val.to_f
  end

  # line's index within document
  def index
    self.document.lines.index(self)
  end

  def line_num
    index + 1
  end
end

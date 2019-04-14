class Line < ApplicationRecord
  belongs_to :document
  before_save :handle_change
  before_create :ensure_index

  def handle_change
    @dirty ||= true
    if input_changed? || @dirty
      reprocess
      @dirty = nil
    end
  end

  def ensure_index
    self.index = self.document.next_line_index if self.index.nil?
  end

  def reprocess
    process_expression
    evaluate_result
    # save_variable
  end

  def reprocess!
    reprocess
    self.save
  end

  def result
    result_formatted if display_result?
  end

  def result_raw
    self.read_attribute(:result) 
  end

  def write(text)
    self.update(input: text)
  end

  # line's index within document
  # if index is nil (when line hasn't been saved yet)
  # assume future index based on document's line length
  def calculate_index
    self.document.line_index(self) || self.document.next_line_index
  end

  def line_num
    self.index ? self.index + 1 : 0
  end

  def name
    self.read_attribute(:name) || default_name
  end

  # if a line does not have explicit 
  # variable assignment (`[VAR] = ...`)
  # the default name is `line[NUM]`
  def default_name
    return "line#{line_num}"
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

  # if line is a non-calculation
  # (does not have a processed expression)
  # such as: 'comment' or 'invalid'
  # then no result should be displayed
  def display_result?
    has_expression?
  end

  private
 
  def evaluate_result
    self.result = document.eval(self.expression)
  end
 
  # uses LineProcessor to convert raw input
  # into a pure mathmatical expression
  def process_expression
    processor = LineProcessor.new(self.input)
    self.name = processor.name || default_name
    self.expression = processor.expression
    self.mode = processor.mode.to_s
    # save_variable
  end

  # recast result if it can be expressed as an integer
  # e.g. 1.0 => 1
  def result_formatted
    result_val = self.read_attribute(:result)
    
    if !result_val
      return nil
    elsif !result_val.is_a? Numeric
      return result_val
    elsif result_val == result_val.to_i
      return result_val.to_i
    else
      return result_val.to_f
    end
  end

  def save_variable
    # puts "[save] #{self}: #{self.name}"
    # self.document.save_variable(self.name, self) if display_result?
    self.document.save_line(self)
  end
end

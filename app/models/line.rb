class Line < ApplicationRecord
  belongs_to :document
  before_save :reprocess

  def reprocess
    if input_changed?
      reload_processed
      reload_result
    end
  end

  def result
    result_formatted
  end

  private
 
  def evaluated_result
    document.eval(processed)
  end

  def reload_processed
    self.processed = processed_input
  end

  def reload_result
    self.result = evaluated_result
  end
 
  def processed_input
    # for now just pass raw input into processed input
    self.input
  end

  def result_formatted
    # recast result if it can be expressed as an integer
    # e.g. 1.0 => 1, 1.1 => 1.1
    result_val = self.read_attribute(:result)
    result_val == result_val.to_i ? result_val.to_i : result_val.to_f
  end
end

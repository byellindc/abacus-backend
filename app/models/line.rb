class Line < ApplicationRecord
  belongs_to :document

  before_save :reprocess

  def reprocess
    if self.input_changed?
      self.reload_processed
      self.reload_result
    end
  end
  
  def processed_input
    # for now just pass raw input into processed input
    self.input
  end

  def evaluated_result
    self.document.eval(self.processed)
  end

  def reload_processed
    self.processed = self.processed_input
  end

  def reload_result
    self.result = self.evaluated_result
  end

  def result_formatted
    # truncate any unecessary zeros
  end
end

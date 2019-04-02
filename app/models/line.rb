class Line < ApplicationRecord
  belongs_to :document
  after_update :update_result

  private
  
  def process_input
    # for now just pass raw input into processed input
    self.processed = self.input
  end

  def update_result
    self.process_input
    self.result = self.eval
  end

  def eval
    self.document.eval(self.processed)
  end
end

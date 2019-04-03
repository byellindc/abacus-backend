class Line < ApplicationRecord
  belongs_to :document

  # before_update :update_result
  # before_create :update_result

  # skip_callback :update, :after, :update_result
  # skip_callback :create, :after, :update_result

  def update_result
    self.process_input
    self.result = self.eval
    self.save
  end

  def eval
    self.document.eval(self.processed)
  end
  
  def process_input
    # for now just pass raw input into processed input
    self.processed = self.input
  end

  def process_input!
    self.process_input
    self.save
  end

  def result_formatted
    # truncate any unecessary zeros
  end
end

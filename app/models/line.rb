class Line < ApplicationRecord
  belongs_to :document

  def result
    update_result if should_update? 
    read_attribute(:result)
  end
  
  private 

  def should_update?
    self.updated? || !read_attribute(:result)
  end

  def update_result
    # actually update the result
    self.updated = false
  end
end

class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, dependent: :destroy

  def eval(expression)
     calculator.eval(expression)
  end

  private 

  def calculator
    @calculator ||= Calculator.new
  end
end

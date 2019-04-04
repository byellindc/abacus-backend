class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, dependent: :destroy

  def eval(expression)
    calculator.eval(expression)
  end

  def raw_total
    lines.inject(0) {|total, l| total + l.result}
  end

  def total
    # recast total if it can be expressed as an integer
    # e.g. 1.0 => 1, 1.1 => 1.1
    total_val = raw_total
    total_val == total_val.to_i ? total_val.to_i : total_val.to_f
  end

  private 

  def calculator
    @calculator ||= Calculator.new
  end
end

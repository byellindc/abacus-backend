class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, dependent: :destroy

  DEFAULT_TITLE = 'Untitled'
  after_create :ensure_title

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

  def ensure_title
    # if no title is specified, generate incremented default
    self.update(title: Document.next_default_title) if !self.title
  end

  def self.last_default_title
    # returns last title of default-titled document ('Untitled...')
    Document
      .where("title LIKE :prefix", prefix: "#{DEFAULT_TITLE}%")
      .pluck(:title).last || DEFAULT_TITLE
  end

  def self.last_default_index
    # returns last numeric value of default-titled document
    # defaults to 1
    index = Document.last_default_title.scan(/\d+/).first.to_i
    index == 0 ? 1 : index
  end

  def self.next_default_index
    Document.last_default_index + 1
  end

  def self.next_default_title
    "#{DEFAULT_TITLE} #{Document.next_default_index}"
  end

  private 

  def calculator
    @calculator ||= Calculator.new
  end
end

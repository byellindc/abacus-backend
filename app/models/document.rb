require 'dentaku'

class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { order(index: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :lines

  DEFAULT_TITLE = 'Untitled'
  after_create :ensure_title

  after_initialize :setup_calc
  # attr_reader :calculator, :store

  # returns only lines that are valid calculations
  # (lines that have a numeric result)
  def calculation_lines
    self.lines.select(&:has_result?)
    # valid_calc_lines = []

    # self.lines.each do |line|
    #   if line.is_calculation?
    #     if line.has_result?
    #       valid_calc_lines << line
    #     else
    #       line.update(mode: 'invalid')
    #     end
    #   end
    # end

    # return valid_calc_lines
  end

  def raw_total
    calculation_lines.inject(0) {|total, l| total + l.result}
  end

  # recast total if it can be expressed as an integer
  # e.g. 1.0 => 1, 1.1 => 1.1
  def total
    total_val = raw_total
    total_val == total_val.to_i ? total_val.to_i : total_val.to_f
  end

  def line_index(line)
    self.lines.index(line)
  end
  
  def next_line_index
    self.lines.length
  end

  # returns saved Line instance
  def new_line(input, index = nil)
    Line.create!(document: self, input: input, index: index)
  end

  def setup_calc
    # @calculator = Calculator.new
    @calc = Dentaku::Calculator.new
    # @store = {}
  end

  def reprocess
    !!self.lines.each(&:reprocess)
  end

  def eval(expression_or_line)
    reload_variables
    
    if expression_or_line.is_a? Line
      expression = line.expression
    else
      expression = expression_or_line
    end

    @calc.evaluate(expression)
    # calculator.eval(expression)
    # Dentaku(expression, variables)
  end

  def save_variable(name, value)
    # calculator.save(name, value)
    # @store[name] = value
  end

  def save_line(line)
    if line.result
      # puts "[save_line:#{self.object_id}] #{line.name}: #{line.result}"
      # puts "[calc:#{@calculator.object_id}]"
      save_variable(line.name, line.result) 
    end
  end

  def variables
    # calculator.variables  
    # @store

    vars = {}
    self.calculation_lines.each do |line|
      vars[line.name] = line.expression
    end

    return vars
  end

  def reload_variables
    # calculator.store(variables)
    @calc.store(variables)
  end

  # # if non-blank expression is invalid
  # # then mark mode as :invalid
  # def valid_line?(line)
  #   if !line.expression || line.expression.blank?
  #     return
  #   elsif !Calculator.valid?(@expression)
  #     @expression = nil
  #     @mode = :invalid
  #   end
  # end

  # def store
  #   calculator.store
  # end

  # if no title is specified, generate incremented default
  def ensure_title
    self.update(title: Document.next_default_title) if !self.title
  end

  # returns last title of default-titled document ('Untitled...')
  def self.last_default_title
    Document
      .where("title LIKE :prefix", prefix: "#{DEFAULT_TITLE} %")
      .pluck(:title).last || DEFAULT_TITLE
  end

  # returns last numeric value of default-titled document
  # defaults to 1
  def self.last_default_index
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

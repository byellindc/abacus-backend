require 'dentaku'
require_relative '../helpers/numeric_helper'

class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, -> { order(index: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :lines

  DEFAULT_TITLE = 'Untitled'
  after_create :ensure_title
  after_update :handle_change

  after_initialize :setup
  attr_reader :calc, :store 
  attr_reader :expressions, :results

  def setup
    @store = {}
    @expressions = {}
    @results = {}
  end

  # ensure content being called is always a string
  def safe_content
    self.read_attribute(:content) || ""
  end
  
  def line_inputs
    self.safe_content.split('\n')
  end

  def line_inputs=(inputs)
    # if our first input is blank remove it from array to
    # prevent unnecessary newline at start
    inputs.shift if inputs[0].nil? || inputs[0].blank?
    self.update(content: inputs.join('\n'))
  end

  def lines
    @_lines ||= generate_lines
  end

  def total
    calculation_lines.inject(0) {|total, l| total + l.result}
  end

  def total_formatted
    simplify_number(total)
  end

  def line_index(line)
    self.lines.index(line)
  end
  
  def next_line_index
    self.lines.length
  end

  def add_line(input)
    self.line_inputs = [self.line_inputs, input]
  end

  def add_blank_line
    self.add_line('')
  end

  def add_lines(*inputs)
    self.line_inputs = [self.line_inputs, *input]
  end

  # def line_updated(line)
  #   calculate_results
    
  #   if line.name && line.result
  #     @results[line.name] = line.result
  #   end
  # end

  def process_lines
    process_variable_assignments
    process_line_syntax
    process_result_calculations
  end

  def process_variable_assignments
    @store = {}
    @expressions = {}
    
    processor = VariableProcessor.new(self.lines)
    processor.store.each do |var, line|
      @store[var] = line
      @expressions[var] = line.expression
    end
  end

  def process_line_syntax
    self.lines.each do |line|
      LineProcessor.process!(line, self.expressions)
    end
  end

  def process_result_calculations
    self.lines.each do |line| 
      @results[line.name] = calculate_line!(line)
    end
  end

  def calculate_line!(line)
    result = eval_line(line)
    line.result = result
    return result
  end

  def eval_line(line)
    eval(line.expression) if line.is_calculation?
  end

  def eval(expression)
    calculator.evaluate(expression)
    # calculator.eval(expression)
  end

  def variable_names
    self.store.keys
  end

  def result(name)
    self.results[name.to_s]
  end

  def expression(name)
    self.expressions[name.to_s]
  end

  # if content has been updated
  # reset memoized line array
  # reprocess lines
  def handle_change
    if self.content_changed?
      @_lines = nil 
      process_lines
    end
  end

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

  def generate_lines
    line_inputs.map.with_index {|input, i| create_line(input, i)}
  end

  def create_line(input, index)
    Line.new(document: self, index: index, input: input)
  end

  def calculation_lines
    self.lines.select {|l| l.is_calculation? }
  end

  def stored_lines
    self.store.values
  end

  def calculator
    # @calculator ||= Calculator.new
    @calc ||= Dentaku::Calculator.new
  end
end

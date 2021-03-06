require 'json'
require 'dentaku'
require 'ruby-units'
require_relative '../helpers/numeric_helper'

class Document < ApplicationRecord
  # belongs_to :user

  DEFAULT_TITLE = 'Untitled'
  after_create :ensure_title
  after_update :handle_change
  after_initialize :setup

  # attr_reader :calc
  attr_reader :expressions, :results

  def setup
    self.reset
  end

  # content is a newline-separted 
  # string of contents array
  def content
    self.contents.join('\n')
  end

  def content=(newContent)
    new_lines = newContent.split('\n')
    self.update_contents(new_lines)
  end

  def update_contents(newContents)
    self.contents_will_change!
    self.contents = newContents
  end

  def lines
    @lines ||= generate_lines
  end

  def line_index(line)
    self.lines.index(line)
  end
  
  def next_line_index
    self.lines.length
  end

  def add_line(input)
    self.contents_will_change!
    self.contents << input
    self.save!
  end

  def add_blank_line
    self.add_line('')
  end

  def add_lines(*inputs)
    self.contents += inputs
    self.save!
  end

  # def process_lines
  #   @lines = nil 
  #   process_variable_assignments
  #   # process_line_syntax
  #   process_result_calculations
  # end

  def reset
    @lines = nil 
    @store = {}
    @expressions = {}
    @results = {}
    @result_vals = {}
  end

  def process
    self.reset

    VariableProcessor.new(self.lines) do |var, line|
      @store[var] = line
      @expressions[var] = line.expression
      self.calculate_line!(line)

      if line.result
        @results[var] = line.result_formatted
        @result_vals[var] = line.result
        calculator.store(var, line.result)
      end
    end

    return @store
  end

  # def process_line_syntax
  #   self.lines.each do |line|
  #     LineProcessor.process!(line, self.expressions)
  #   end
  # end

  # def process_result_calculations
  #   self.lines.each do |line| 
  #     @results[line.name] = calculate_line!(line)
  #   end
  # end

  def calculate_line!(line)
    LineProcessor.process!(line, self.expressions)

    if !line.result
      result = eval_line(line)
      line.result = result.to_f if result
    end

    if line.is_invalid?
      line.mode = :invalid 
    end

    return result
  end

  def eval_line(line)
    eval(line.expression) 
  end

  def eval(expression)
    calculator.evaluate(expression)
  end

  def store
    @store = self.process if @store.nil? || @store.empty?
    return @store
  end

  def variables
    self.store.select { |name, line| line.result }
  end

  def variable_names
    self.store.keys
  end

  # def expressions
  #   process if !@expressions || @expressions.empty?
  #   @expressions || {}
  # end

  # def results
  #   process if !@results || @results.empty?
  #   @results || {}
  # end

  def result(name)
    self.results[name.to_s]
  end

  def expression(name)
    self.expressions[name.to_s]
  end

  # if content has been updated
  # reprocess lines
  def handle_change
    process if self.contents_changed?
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
    self.contents.map.with_index do |input, i| 
      create_line(input, i)
    end
  end

  def create_line(input, index)
    line = Line.new(document: self, index: index, input: input)
    LineProcessor.process!(line)
    calculate_line!(line)
    return line
  end

  # def content_replacer
  #   ContentReplacer.new(self.result_vals).replace(text)
  # end

  # def replace_vars(text)
  #   content_replacer.replace(text)
  # end

  def format_lines
    replacer = ContentReplacer.new(self.result_vals)
    replacer.case_sensitive = false

    self.lines.each do |line|
      line.expression = replacer.apply(line.expression)
    end
  end

  def calculation_lines
    self.lines.select {|l| l.is_calculation? }
  end

  def stored_lines
    self.store.values
  end

  def calculator
    @calc ||= Dentaku::Calculator.new
  end
end

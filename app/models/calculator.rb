require 'dentaku'

class Calculator
  attr_reader :store
  alias_method :variables, :store

  def initialize
    @internal = Dentaku::Calculator.new
    @store = {}
  end

  # if expression evaluates to nil
  # then assume invalid
  def self.valid?(expression)
    !!Calculator.new.eval(expression)
  end

  def eval(expression)
    Dentaku(expression, self.store)
    # @internal.evaluate(expression)
  end

  def eval!(expression)
    @internal.evaluate!(expression)
  end

  # store key/value variables pairs
  def save(key, value)
    @store[key] = value
    # puts "[save:#{@internal.object_id}] #{key}: #{value}"
    # !!@internal.store(key, value)
  end

  def variable_names
    variables.keys
  end
end
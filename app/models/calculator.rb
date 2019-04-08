require 'dentaku'

class Calculator
  def initialize
    @internal = Dentaku::Calculator.new
  end

  # if expression evaluates to nil
  # then assume invalid
  def self.valid?(expression)
    !!Calculator.new.eval(expression)
  end

  def eval(expression)
    @internal.evaluate(expression)
  end

  def eval!(expression)
    @internal.evaluate!(expression)
  end

  # store key/value variables pairs
  def save(key, value)
    @internal.store(key, value)
  end

  def variables
    @internal.memory
  end

  def variable_names
    variables.keys
  end
end
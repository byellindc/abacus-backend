require 'dentaku'

class Calculator
  def initialize()
    @store = {}
    @internal = Dentaku::Calculator.new
  end

  # store key/value variables pairs
  def store(key, value)
    @store[key] = value
    @internal.store(key, value)
  end

  def eval(expression)
    @internal.evaluate(expression)
  end
end
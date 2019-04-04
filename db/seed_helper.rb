# seed utils

OPERATORS = %w(+ - * /)

def rand_operator
  OPERATORS.sample
end

def rand_math_expression(min: 1, max: 500, wrap: false)
  tokens = [rand(min..max), rand_operator, rand(min..max)]
  expr = tokens.join(' ')
  expr = "(#{expr})" if wrap
  return expr
end

def rand_math_expressions
  expressions = []
  len = rand(1..3)

  len.times do |i|
    expr = rand_math_expr
    wrap = len > 1 && rand(0..2) == 0

    if i == (len-1)
      expressions << rand_math_expression(wrap: wrap)
    else
      expressions << "#{rand_math_expression(wrap: wrap)} #{rand_operator}"
    end
  end

  expressions.join(' ')
end
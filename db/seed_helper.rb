# seed utils

def rand_operator
  %w(+ - * /).sample
end

# random number between min/max
# with occassional chance of being a float
def rand_num(min = 1, max = 500)
  if rand(0..4) == 0
    rand(min.to_f..max.to_f).round(2)
  else
    rand(min..max)
  end
end

def rand_math_expression(min: 1, max: 500, wrap: false)
  tokens = [rand_num(min, max), rand_operator, rand_num(min, max)]

  expr = tokens.join(' ')
  expr = "(#{expr})" if wrap

  return expr
end

def rand_math_expressions
  expressions = []
  len = rand(1..3)

  len.times do |i|
    expr = rand_math_expression
    wrap = len > 1 && (rand(0..2) == 0)

    if i == (len-1)
      expressions << rand_math_expression(wrap: wrap)
    else
      expressions << "#{rand_math_expression(wrap: wrap)} #{rand_operator}"
    end
  end

  expressions.join(' ')
end

def rand_percentage_expression
  operator = %w(of off on).sample
  ["#{rand_num(2, 60)}%", operator, rand_num].join(' ')
end
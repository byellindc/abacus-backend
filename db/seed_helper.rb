# seed utils

def rand_doc_title
  titles = %w(Bills Utilities Trip Project Untitled DIY Expenses)
  "#{titles.sample} #{rand(1..9)}"
end

def rand_book_title(max = 18)
  book = Faker::Base.translate('faker.book.title').reject {|t| t.length > max}.sample
  return book.gsub(/(^The |^A |\s*\W$)/, '').gsub(/\s+$/, '')
end

def rand_title
  (rand(0..5) == 0) ? rand_book_title : rand_doc_title
end

def rand_name
  Faker::FunnyName.unique.name
end

def rand_username(name = nil)
  Faker::Internet.username(name, %w(_ -))
end

def rand_email(name = nil)
  Faker::Internet.email(name)
end

def rand_person
  name = rand_name
  {name: name, username: rand_username(name), email: rand_email(name)}
end

def rand_comment
  case rand(0..3)
  when 0
    "// #{Faker::Lorem.characters(rand(5..15))}"
  when 1
    "// #{Faker::Lorem.sentences(rand(1..2))}"
  when 2
    "// #{Faker::Lorem.question}"
  else
    "// #{Faker::Lorem.words(rand(3..20))}"
  end
end

def rand_word(min: 4, max: 15, filter: '')
  dict = "/usr/share/dict/words"
  selected_word = nil

  File.foreach(dict).select do |word|
    word.length >= min && 
    word.length <= max && 
    word.include?(filter)
  end.sample.chomp.downcase
end

def rand_var
  if rand(0..4) == 0
    "#{rand_word(max: 5)}_#{rand_word(max: 5)}"
  else
    "#{rand_word(max: 12)}"
  end
end

def rand_operator
  %w(+ - * /).sample
end

def num_precision(num)
  num.to_s.split('.')[1].try(:length) || 0
end

def is_float?(num)
  num.to_i != num.to_f
end

# random number between min/max
# with occassional chance of being a float
def rand_round_num(min = 1, max = 500, round = nil)
  min_precision = num_precision(min)
  max_precision = num_precision(max)
  precision = (max_precision > min_precision) ? max_precision : min_precision 

  if round.nil? && precision == 0
    round = (rand(0..4) == 0) ? 2 : 0
  elsif round.nil?
    round = precision || 0
  end

  # round = num_precision(min) if !round && !is_float?(max)
  # round = num_precision(max) if !round && !is_float?(min)

  rand(min.to_f..max.to_f).round(round)
end

def rand_decimal(min = nil, max = nil, round = nil)
  rand_round_num(min, max, round || rand(2..8))
end

# random number between min/max
# with occassional chance of being a float
def rand_num(min = 1, max = 500, decimal = nil)
  decimal = (rand(0..4) == 0) if !decimal
  if decimal
    rand(min.to_f..max.to_f).round(2)
  else
    rand(min..max)
  end
end

def rand_math_expression(min: 1, max: 500, wrap: false, decimal: nil, nums: [])
  nums << rand_num(min, max, decimal) if nums.length < 1
  nums << rand_num(min, max, decimal) if nums.length < 2

  tokens = nums[0..-2].map do |n| 
    [n, rand_operator]
  end.flatten

  tokens << nums[-1]

  # tokens = [nums[0], rand_operator, nums[1]]

  expr = tokens.join(' ')
  expr = "(#{expr})" if wrap
  return expr
end

def rand_math_expressions(nums = [])
  # nums.shuffle! if nums

  expressions = []
  len = rand(1..3)

  len.times do |i|
    expr = rand_math_expression
    wrap = len > 1 && (rand(0..2) == 0)
    expr_nums = nums.pop(2)

    if i == (len-1)
      expressions << rand_math_expression(wrap: wrap, nums: expr_nums)
    else
      expressions << "#{rand_math_expression(wrap: wrap, nums: expr_nums)} #{rand_operator}"
    end
  end

  expressions.join(' ')
end

def rand_invalid_expression
  case rand(0..3)
  when 0
    "#{rand_num} #{rand_operator}"
  when 1
    nums = [rand_num, "#{rand_num(nil, nil, false)}."]
    rand_math_expression(nums.shuffle)
  else
    "#{rand_calculable} #{rand_operator} #{rand_var}"
  end
end

def rand_calculable
  if rand(0..1) == 0
    rand_num
  else
    rand_math_expression
  end
end

def rand_percentage_expression
  operator = %w(of off on).sample
  ["#{rand_num(2, 60)}%", operator, rand_calculable].join(' ')
end

def rand_var_expression
  "#{rand_var} = #{rand_calculable}"
end

def rand_line_input
  case rand(0..6)
  when 0
    rand_var_expression
  when 1
    rand_percentage_expression
  when 2
    rand_comment
  else
    rand_calculable
  end
end
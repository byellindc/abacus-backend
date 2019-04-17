require 'database_cleaner'
require_relative 'seed_helper'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# user seeds 

users = []
pass = "123"

admin = User.create!(
  name: "admin",
  username: "admin",
  password: pass
)

2.times do
  person = rand_person
  users << User.create!(
    name: person[:name], 
    username: person[:username],
    email: person[:email],
    password: pass
   )
end

# document seeds

doc = Document.create!(
  title: "Untitled"
)

doc2 = Document.create!(
  title: "Untitled 2"
)

Document.create!(title: rand_title)
Document.create!(title: rand_title)
Document.create!(title: rand_title)

# 3.times.do 
#   Document.create!(
#     user: users.sample, 
#     title: rand_doc_title
#   )
# end

# line seeds

new_line('// basic')
new_line('1+1')
new_line('test = 2 + 8')
new_line('40 * 0.74')
new_line('8/2')
new_line('2.2 * 3')
new_line('1 + test')
new_line('')

new_line('// percentages')
new_line('10% of 30')
new_line('30% off 89.99')
new_line('5% on 12')
new_line('')

new_line('// conversion')
new_line('10.2 km as m')
new_line('22 ft in in')
new_line('')

new_line('// misc')
new_line('6 + error')

# 5.times {|i| new_line }
# 5.times {|i| new_line(rand_math_expression) }

# Line.create!(
#   input: "1+1",
#   document: doc
# )

# Line.create!(
#   input: "1+2",
#   document: doc
# )

# Line.create!(
#   input: "2.2*8",
#   document: doc
# )

# Line.create!(
#   input: "// this is a comment",
#   document: doc
# )

# Line.create!(
#   input: "8 * huh",
#   document: doc
# )

# Line.create!(
#   input: "1+1",
#   document: doc2
# )
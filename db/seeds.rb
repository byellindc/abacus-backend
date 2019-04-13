require 'database_cleaner'
require_relative 'seed_helper'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# user seeds 

default_pass = '123'
users = []

admin = User.create!(
  name: "admin",
  username: "admin",
  password: "123"
)

5.times do
  user = rand_person
  users << User.create!(
    name: user.name, 
    username: user.username
    email: user.email
   )
end

# document seeds

docs = []

docs << Document.create!(
  user: admin,
  title: "Untitled"
)

doc2 << Document.create!(
  user: admin,
  title: "Untitled 2"
)

3.times.do 
  docs << Document.create!(
    user: users.sample, 
    title: rand_doc_title
  )
end

# line seeds

def new_line(input = nil, doc = doc)
  input = rand_line_input if input.nil?
  Line.create!(input: "1+1", document: docs[0])
end

new_line('// basic')
new_line('1+1')
new_line('2 + 8')
new_line('40 * 0.74')
new_line('8/2')
new_line('2.2 * 3')
new_line('')

new_line('// percentages')
new_line('10% of 30')
new_line('30% off 89.99')
new_line('5% on 12')
new_line('')

new_line('// misc')
new_line('6 + error')
5.times {|i| new_line }
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

Line.create!(
  input: "1+1",
  document: doc2
)
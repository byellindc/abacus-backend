require 'database_cleaner'
require_relative 'seed_helper'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# user seeds 

bob = User.create!(
  name: "Bob",
  username: "bob",
  password: "123"
)

# document seeds

doc = Document.create!(
  user: bob,
  title: "Untitled"
)

doc2 = Document.create!(
  user: bob,
  title: "Untitled 2"
)

# line seeds

Line.create!(
  input: "1+1",
  document: doc
)

Line.create!(
  input: "1+2",
  document: doc
)

Line.create!(
  input: "2.2*8",
  document: doc
)

Line.create!(
  input: "1+1",
  document: doc2
)
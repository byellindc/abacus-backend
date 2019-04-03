require 'database_cleaner'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

bob = User.create!(
  name: "Bob",
  username: "bob",
  password: "123"
)

doc = Document.create!(
  user: bob,
  title: "Untitled"
)

doc2 = Document.create!(
  user: bob,
  title: "Untitled 2"
)

Line.create!(
  input: "1+1",
  processed: "1+1",
  result: 2,
  document: doc
)

Line.create!(
  input: "1+2",
  processed: "1+2",
  result: 3,
  document: doc
)

Line.create!(
  input: "1+1",
  processed: "1+1",
  result: 2,
  document: doc2
)
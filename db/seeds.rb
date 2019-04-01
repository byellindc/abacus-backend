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
  title: 'Untitled'
)
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

User.create!(
  name: "Bob",
  username: "bob",
  password: "123"
)
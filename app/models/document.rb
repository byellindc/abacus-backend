class Document < ApplicationRecord
  belongs_to :user
  has_many :lines, dependent: :destroy
end

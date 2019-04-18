class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, :contents,
    :created_at, :updated_at, :variables
  has_many :lines
end

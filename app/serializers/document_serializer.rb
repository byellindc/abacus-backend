class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, 
    :total, :raw_total,
    :created_at, :updated_at
  has_many :lines
end

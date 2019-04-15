class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :total, 
    :raw_total, :created_at, :updated_at
  has_many :lines
end

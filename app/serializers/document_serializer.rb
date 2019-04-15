class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, :content,
    :created_at, :updated_at, :lines
end

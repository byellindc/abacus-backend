class DocumentSerializer < ActiveModel::Serializer
  attributes :id, :title, :contents,
    :created_at, :updated_at, :lines
end

class LineSerializer < ActiveModel::Serializer
  attributes :id, :input, :processed, :name, :result, :document_id
  belongs_to :document
end

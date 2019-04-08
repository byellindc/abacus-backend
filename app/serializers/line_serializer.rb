class LineSerializer < ActiveModel::Serializer
  attributes :id, :input, :processed, :name, :result, :type, :document_id
  belongs_to :document
end

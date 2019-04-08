class LineSerializer < ActiveModel::Serializer
  attributes :id, :input, :expression, :name, :result, :mode, :document_id
  belongs_to :document
end

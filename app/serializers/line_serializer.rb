class LineSerializer < ActiveModel::Serializer
  attributes :id, :index, :input, :expression, :name, :result, :mode, :document_id, :created_at, :updated_at
  belongs_to :document
end

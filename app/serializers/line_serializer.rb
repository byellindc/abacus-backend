class LineSerializer < ActiveModel::Serializer
  attributes :id, :document_id,
    :mode, :index, :input, :expression, 
    :name, :result, :created_at, :updated_at
  belongs_to :document
end

class LineSerializer < ActiveModel::Serializer
  attributes :document_id, :input, :expression, 
    :mode, :name, :result, :result_formatted
end

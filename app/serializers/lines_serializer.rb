class LinesSerializer < ActiveModel::Serializer
  attributes :id, :input, :processed, :name, :result
  belongs_to :document
end

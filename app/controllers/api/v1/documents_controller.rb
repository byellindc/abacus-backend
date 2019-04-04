class Api::V1::DocumentsController < ApplicationController
  def index
    documents = Document.all.order(:created_at)
    render json: documents, status: :accepted
  end
  
  def show
    @document = Document.find(params[:id])
    render json: @document, status: :accepted
  end
end

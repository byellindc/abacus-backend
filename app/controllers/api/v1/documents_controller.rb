class Api::V1::DocumentsController < ApplicationController
  before_action :get_document, except: %i(index)
  
  def index
    documents = Document.all.order(:created_at)
    render json: documents, status: :accepted
  end
  
  def show
    render json: @document, status: :accepted
  end
  
  def update
    @document.update(document_params)
    if @document.save
      render json: @document, status: :accepted
    else
      render json: { errors: @document.errors.full_messages }, status: :unprocessible_entity
    end
  end

  private

  def document_params
    params.permit(:title,)
  end

  def get_document
    @document = Document.find(params[:id])
  end
end

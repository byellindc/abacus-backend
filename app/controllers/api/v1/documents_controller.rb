class Api::V1::DocumentsController < ApplicationController
  def index
    render json: Document.all, status: :accepted
  end
  
  def show
    @document = Document.find(params[:id])
    render json: @document, status: :accepted
  end
end

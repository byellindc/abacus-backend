class Api::V1::DocumentsController < ApplicationController
  before_action :get_document, except: %i(index create destroy)
  
  def index
    documents = Document.all.order(:created_at)
    render json: documents, status: :accepted
  end
  
  def show
    render json: @document, status: :accepted
  end

  def create
    document = Document.create(document_params)
    document.add_line('// type your calculations here')
    document.add_line('1 + 1')
    document.add_blank_line

    render json: document, status: :accepted
  end
  
  def update
    @document.update(document_params)
    @document.update_contents(params[:contents]) if params[:contents]

    if @document.save
      render json: @document, status: :accepted
    else
      render json: { errors: @document.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def destroy
    document = Document.find(params[:id])
    document.destroy()
    render json: document, status: :accepted
  end

  private

  def document_params
    params.require(:document).permit(:title, :contents, lines: [:document_id, :input])
  end

  def get_document
    @document = Document.find(params[:id])
  end
end

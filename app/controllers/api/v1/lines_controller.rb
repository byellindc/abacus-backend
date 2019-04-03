class Api::V1::LinesController < ApplicationController
  before_action :get_document
  before_action :get_line, except: %i(index)

  def index
    render json: @document.lines, status: :accepted
  end
  
  def show
    render json: @line, status: :accepted
  end

  def update
    @line.update(line_params)
    if @line.save
      render json: @line, status: :accepted
    else
      render json: { errors: @line.errors.full_messages }, status: :unprocessible_entity
    end
  end
  
  private

  def line_params
    params.permit(:input)
  end

  def get_document
    @document = Document.find(params[:document_id])
  end

  def get_line
    @line = @document.find(params[:id])
  end
end

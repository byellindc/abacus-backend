class Api::V1::LinesController < ApplicationController
  def index
    render json: document.lines, status: :accepted
  end
  
  def show
    render json: line, status: :accepted
  end

  def create
    line = Line.create(line_params)
    render json: line, status: :accepted
  end

  def update
    line.update(line_params)
    line.reprocess

    if line.save
      render json: line, status: :accepted
    else
      render json: { errors: line.errors.full_messages }, status: :unprocessible_entity
    end
  end

  def destroy
    line = Line.find(params[:id])
    line.destroy()
    render json: line, status: :accepted
  end
  
  private

  def line_params
    params.permit(:id, :document_id, :input, :name)
  end

  def document
    @document ||= Document.find(params[:document_id])
  end

  def line
    @line ||= document.lines.find(params[:id])
  end
end

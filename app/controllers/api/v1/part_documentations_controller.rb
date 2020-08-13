module Api
  module V1
    class PartDocumentationsController < ApplicationController
      before_action :set_part_documentation, only: [:show, :update, :destroy]

      # GET /part_documentations
      def index
        @part_documentations = PartDocumentation.all

        render json: @part_documentations
      end

      # GET /part_documentations/1
      def show
        render json: @part_documentation
      end

      # POST /part_documentations
      def create
        @part_documentation = PartDocumentation.new(part_documentation_params)

        if @part_documentation.save
          render json: @part_documentation, status: :created, location: @part_documentation
        else
          render json: @part_documentation.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /part_documentations/1
      def update
        if @part_documentation.update(part_documentation_params)
          render json: @part_documentation
        else
          render json: @part_documentation.errors, status: :unprocessable_entity
        end
      end

      # DELETE /part_documentations/1
      def destroy
        @part_documentation.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_part_documentation
          @part_documentation = PartDocumentation.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def part_documentation_params
          params.require(:part_documentation).permit(:part_number, :customer_id, :machine_id, :program_number, :revision_no, :editor, :part_produced_in_this_setup, :job_number, :part_drawing)
        end
    end
  end
end

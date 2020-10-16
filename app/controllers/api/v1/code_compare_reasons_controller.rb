module Api
  module V1
    class CodeCompareReasonsController < ApplicationController
      before_action :set_code_compare_reason, only: [:show, :update, :destroy]
      #skip_before_action :authenticate_request, only: %i[index]

      # GET /code_compare_reasons
    def index
      page = params[:page].present? ? params[:page] : 1
      page_count = params[:per_page].present? ? params[:per_page] : 10
      if params["id"].present? && params["search"].present?
        rec = Machine.find(params[:id]).code_compare_reasons
        reasons = CodeCompareReason.data_s(params)#.paginate(:page => page, :per_page => page_count)
        result = reasons.select{|i| i.machine_id == params["id"].to_i}
        rec = result.first(10)
        render json: rec
      elsif params["id"].present?
        rec = Machine.find(params[:id]).code_compare_reasons.first(10)#.paginate(:page => page, :per_page => page_count)
        render json: rec
      else
        render json: "ok"
      end
    end

    def part_doc_search
      page = params[:page].present? ? params[:page] : 1
      page_count = params[:per_page].present? ? params[:per_page] : 10
      if params["id"].present? && params["search"].present?
        rec = Machine.find(params[:id]).code_compare_reasons
        reasons = CodeCompareReason.data_s(params)#.paginate(:page => page, :per_page => page_count)
        result = reasons.select{|i| i.machine_id == params["id"].to_i}
        rec = result.first(10)
        render json: rec
      elsif params["id"].present?
        rec = Machine.find(params[:id]).code_compare_reasons.first(10)#.paginate(:page => page, :per_page => page_count)
        render json: rec
      else
        render json: "ok"
      end
    end

      # GET /code_compare_reasons/1
      def show
        render json: @code_compare_reason
      end

      # POST /code_compare_reasons
      def create
        if params[:machine_id].present?
          @code_compare_reason = CodeCompareReason.new(code_compare_reason_params)

          if @code_compare_reason.save
            render json: @code_compare_reason, status: :created, location: @code_compare_reason
          else
            render json: @code_compare_reason.errors, status: :unprocessable_entity
          end
        else
          render json: {status: "Give the machine id"}
        end
      end

      # PATCH/PUT /code_compare_reasons/1
      def update
        if @code_compare_reason.update(code_compare_reason_params)
          render json: @code_compare_reason
        else
          render json: @code_compare_reason.errors, status: :unprocessable_entity
        end
      end

      # DELETE /code_compare_reasons/1
      def destroy
        @code_compare_reason.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_code_compare_reason
          @code_compare_reason = CodeCompareReason.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def code_compare_reason_params
          params.require(:code_compare_reason).permit! # (:user_id, :machine_id, :description, :current_location, :status, :file_path)
        end
    end
  end
end

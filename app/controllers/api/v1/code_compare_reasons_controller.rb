module Api
  module V1
    class CodeCompareReasonsController < ApplicationController
      before_action :set_code_compare_reason, only: [:show, :update, :destroy]
      skip_before_action :authenticate_request, only: %i[index]

      # GET /code_compare_reasons
      def index
	if params["tenant_id"].present? && params["id"] == "ALL" || params["id"] == "undefined" && params["id"].present?
	  mac_ids = Machine.where(tenant_id: params["tenant_id"]).pluck(:id)
	  code_compare_reasons = CodeCompareReason.where(machine_id: mac_ids)
	  render json: code_compare_reasons
        elsif params["id"] != "ALL" || params["id"] != "undefined" && params["id"].present?
          code_compare_reasons = CodeCompareReason.where(machine_id: params[:id])
          render json: code_compare_reasons
        else
          render json: {status: "Please Select the Machine"}
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

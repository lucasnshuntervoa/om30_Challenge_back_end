# frozen_string_literal: true

module Api
  module V1
    class CitizensController < ActionController::API
      before_action :set_citizen, only: %i[show update]

      def index
        citizens = filter_citizens(Citizen.includes(:addresses), params)
        render json: citizens, each_serializer: CitizenSerializer
      end

      def show
        render json: @citizen, serializer: CitizenSerializer
      end

      def create
        citizen = Citizen.new(citizen_params)
        if citizen.save
          render json: citizen, serializer: CitizenSerializer, status: :created
        else
          render json: citizen.errors, status: :unprocessable_entity
        end
      end

      def update
        if @citizen.update(citizen_params)
          render json: @citizen, serializer: CitizenSerializer
        else
          render json: @citizen.errors, status: :unprocessable_entity
        end
      end

      private

      def filter_citizens(scope, params)
        scope = scope.where('citizens.name LIKE ?', "%#{params[:name]}%") if params[:name].present?
        scope = scope.where('citizens.last_name LIKE ?', "%#{params[:last_name]}%") if params[:last_name].present?
        scope = scope.where('citizens.cpf LIKE ?', "%#{params[:cpf]}%") if params[:cpf].present?
        scope = scope.where('citizens.cns LIKE ?', "%#{params[:cns]}%") if params[:cns].present?

        if params[:city].present? || params[:state].present?
          scope = scope.joins(:addresses)
          scope = scope.where('addresses.city = ?', params[:city]) if params[:city].present?
          scope = scope.where('addresses.state = ?', params[:state]) if params[:state].present?
        end

        scope.page(params[:page]).per(params[:per_page])
      end

      def set_citizen
        @citizen = Citizen.find(params[:id])
      end

      def citizen_params
        params.require(:citizen).permit(:id, :name, :last_name, :cpf, :status, :cns, :date_of_birth, :status, :cpf,
                                        :telephone, :email, :photo, addresses_attributes: %i[id street city state complement neighborhood postal_code ibge_code])
      end
    end
  end
end

module Api
  module V1
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  skip_before_action :authenticate_request, only: %i[email_validation]
   
  # GET /users
  def index
    # role_ids = Role.where(tenant_id: params[:tenant_id]).where.not(role_name: "CEO").pluck(:id)
    # users = User.where(tenant_id:params[:tenant_id]).where.not(role_id:1)
    # users = User.where(tenant_id:params[:tenant_id], role_id: role_ids)
    users = Tenant.find(params[:tenant_id]).users.where.not(role_id: Tenant.find(params[:tenant_id]).roles.where(role_name: "CEO")[0].id)
    render json: users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
   # @user = User.new(user_params)
    # @user = User.new(first_name: params[:first_name], last_name: params[:last_name], email_id: params[:email_id], password: params[:password], phone_number: params[:phone_number], remarks: params[:remarks], usertype_id: params[:usertype_id], approval_id: params[:approval_id], tenant_id: params[:tenant_id], role_id: params[:role_id],isactive: true)
    role_id = Role.find_by(tenant_id: params[:tenant_id], role_name: params[:role_id]).id
    # @user = User.new(first_name: params[:first_name], last_name: params[:last_name], email_id: params[:email_id], password: params[:password], phone_number: params[:phone_number], remarks: params[:remarks], usertype_id: params[:usertype_id], tenant_id:params[:tenant_id], role_id:params[:role_id], default: params[:password],isactive: false)
    @user = User.new(first_name: params[:first_name], last_name: params[:last_name], email_id: params[:email_id], password: params[:password], phone_number: params[:phone_number], remarks: params[:remarks], usertype_id: params[:usertype_id], tenant_id:params[:tenant_id], role_id: role_id, default: params[:password],isactive: false)

    if @user.save
      render json: @user, status: :created#, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def pending_approvals
    # all_users = User.approval_pending
    # render json: all_users
   data = Tenant.where(isactive: [nil, false])
   render json: data
  end

  # PATCH/PUT /users/1
  def update
    # role_id = params[:role_id].present? ? Role.find_by(tenant_id: params[:tenant_id], role_name: params[:role_id]).id : @user.id
    if params[:role_id].is_a? Integer
      role_id = params[:role_id]
    else
      # role = params[:role_id].split(' ')
      role_id = Role.find_by(role_name: params[:role_id]).id
      # role_id = Role.find_by(tenant_id: params[:tenant_id], role_name: params[:role_id]).id
      # role_id = Role.find_by(tenant_id: params[:tenant_id], role_name: role).id
    end
    if @user.update(user_params)
      @user.update(isactive: true, role_id: role_id)
      ApprovalMailer.approval_user(@user).deliver
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

   def approval_list
    role = Role.where(role_name: "CEO").ids

    user = User.includes(:tenant).where(role_id: role, isactive: nil)
   # user = User.where(isactive: nil)
     render json: user
   end


  # DELETE /users/1
  def destroy
    @user.destroy
    render json: true
    #@user.update(isactive:0)
  end

    def admin_user
    @users = User.where(usertype_id: 2)
    render json: @users
  end

  def email_validation
      result=User.email_validation(params)
      render json: result
  end
  

  def password_recovery
    password = User.find_by(email_id:params[:email_id]).present? ? User.find_by(email_id:params[:email_id]).password : false
    
    password = {"password": password}
    render json: password
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_id, :password, :phone_number, :remarks, :usertype_id, :approval_id, :tenant_id, :isactive,:default) #:role_id,
    end
end
end
end

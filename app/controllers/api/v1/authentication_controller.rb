module Api
    module V1
		class AuthenticationController < ApplicationController
			skip_before_action :authenticate_request

			def authenticate

				command = AuthenticateUser.call(params[:email], params[:password])

			    if command.success?
			      render json: { auth_token: command.result }
			    else
			      render json: { error: command.errors }, status: :unauthorized
			    end
			end

			def programmer_login
				if params[:email_id].present?
					@user = User.find_by("email_id LIKE ?", "%#{params[:email_id]}")
					if @user.present?
						if @user.role.present? && @user.role.role_name == "Programmer" || "CEO"
							if @user.authenticate(params[:password])
								token = JsonWebToken.encode(user_id: @user.id)
								tenant_id = @user.tenant_id
								 user_name = "#{@user.first_name} #{@user.last_name}" if @user.present?
								render json: {token: token, tenant_id: tenant_id, user_id: @user.id, user_name: user_name,status: "Login success"}
							else
								render json: {status: "Email or Password incorrect"}
							end
						else
							render json: {status: "You are not allowed to login"}
						end
					else
						render json: {status: "User does not exits"}
					end
				else
					render json: {status: "Give the Email ID"}
				end	
			end

		end
	end
end

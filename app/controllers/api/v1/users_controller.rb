class Api::V1::UsersController < ApplicationController
  before_action :authorize_admin, except: [:set_password, :send_password_reset_email, :reset_password, :index]
  before_action :authorize_teacher, only: [:index]
  before_action :verify_signature, except: [:set_password, :send_password_reset_email, :reset_password]

  def send_new_user_email
    UserMailer.with(params: user_params).set_password_email.deliver_now
  end

  def set_password
    if not_yet_created_user = NotYetCreatedUser.find_by(uuid: user_params[:uuid])
      user_attributes = {
        first_name: not_yet_created_user.first_name,
        last_name: not_yet_created_user.last_name,
        email: not_yet_created_user.email,
        role: not_yet_created_user.role,
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation]
      }
      if user = User.create(user_attributes)
        not_yet_created_user.destroy
        render json: {}, status: 204
      else
        render json: {}, status: 404
      end
    else
      render json: {}, status: 404
    end
  end

  def reset_password
    if password_reset = PasswordReset.find_by(uuid: user_params[:uuid])
      user = password_reset.user
      user.password = user_params[:password]
      user.password_confirmation = user_params[:password_confirmation]
      if user.save
        password_reset.destroy
        render json: {}, status: 204
      else
        render json: {}, status: 404
      end
    else
      render json: {}, status: 404
    end
  end

  def send_password_reset_email
   if user = User.find_by(email: user_params[:email])
      password_reset = PasswordReset.create(user_id: user.id)
      UserMailer.with(params: {first_name: user_params[:first_name], email: user_params[:email], uuid: password_reset.uuid}).reset_password_email.deliver_now
      render json: {}, status: 204
    else
      render json: {}, status: 404
    end
  end

  def index
    if request.fullpath.split('/').last == 'students'
      students = User.where(role: :student)
      students_attributes = students.map do |student|
        {
          id: student.id,
          first_name: student.first_name,
          last_name: student.last_name,
          email: student.email
        }
      end
      students_response = {students: students_attributes}
      render json: students_response
    else
      render json: {}, status: 404
    end
  end

  private

  def user_params
    params.require(:user).permit(:role, :first_name, :last_name, :email, :password, :password_confirmation, :uuid)
  end
end

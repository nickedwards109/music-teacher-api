class Api::V1::Student::DashboardController < ApplicationController
  before_action :authorize_student
  before_action :verify_signature

  def show
    token = request.headers["TOKEN"]
    id = get_id(token)
    user = User.find(id)
    first_name = user.first_name
    render json: {firstName: first_name}, status: 200
  end

  private

  def dashboard_params
    params.permit(:token)
  end
end

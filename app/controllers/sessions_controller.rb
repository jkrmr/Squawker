class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)


    if user && valid_password?(user)
      sign_in user
      redirect_to user
    else
      flash.now[:error] = "Invalid email/password combination"
      # NB: .now contents disappear as soon as there is an additional request
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  private
    def valid_password?(user)
      user.authenticate(params[:session][:password])
    end
end
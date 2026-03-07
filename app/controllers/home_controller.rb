class HomeController < ApplicationController
  before_action :authenticate_user!, only: [ :settings, :update_preferences ]

  def index; end

  def settings; end

  def update_preferences
    if current_user.update(user_preferences_params)
      redirect_to settings_path, notice: "Preferences updated."
    else
      redirect_to settings_path, alert: "Could not update preferences."
    end
  end

  private

  def user_preferences_params
    params.require(:user).permit(:background_image_url)
  end
end

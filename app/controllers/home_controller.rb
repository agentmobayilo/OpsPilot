class HomeController < ApplicationController
  before_action :authenticate_user!, only: [ :settings, :update_preferences ]

  def index
    if user_signed_in? && current_user.active_oauth_connection(:google_oauth2).present?
      @active_connection = current_user.active_oauth_connection(:google_oauth2)
      @email_threads = @active_connection.email_threads.order(created_at: :desc).limit(50)
    end
  end

  def settings; end

  def update_preferences
    if params[:remove_background]
      current_user.background_image.purge if current_user.background_image.attached?
      current_user.update(background_image_url: nil)
      redirect_to settings_path, notice: "Background reset."
      return
    end

    if current_user.update(user_preferences_params)
      redirect_to settings_path, notice: "Preferences updated."
    else
      redirect_to settings_path, alert: "Could not update preferences."
    end
  end

  def sync_inbox
    connection = current_user.active_oauth_connection(:google_oauth2)
    if connection
      GmailSyncJob.perform_later(connection.id)
      redirect_to root_path, notice: "Inbox sync started! Threads will appear shortly."
    else
      redirect_to root_path, alert: "Please connect your Google Workspace account first."
    end
  end

  private

  def user_preferences_params
    params.require(:user).permit(:background_image, :background_image_url)
  end
end

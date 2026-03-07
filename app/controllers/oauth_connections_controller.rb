class OauthConnectionsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    current_user.disconnect_oauth!(params[:provider])
    redirect_to settings_path, notice: "Disconnected #{params[:provider].to_s.humanize}."
  end
end

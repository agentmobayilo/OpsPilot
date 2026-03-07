class OauthConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_connection

  def activate
    current_user.activate_oauth_connection!(@connection)
    redirect_to settings_path, notice: "Switched active Google account."
  end

  def destroy
    current_user.disconnect_oauth!(@connection)
    redirect_to settings_path, notice: "Disconnected Google account."
  end

  private

  def set_connection
    @connection = current_user.oauth_connections.find(params[:id])
  end
end

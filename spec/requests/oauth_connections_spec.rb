require 'rails_helper'

RSpec.describe "OAuthConnections", type: :request do
  let(:user) { User.create!(email: 'user@example.com', password: 'password123') }
  
  before do
    sign_in user
  end

  describe "PATCH /oauth_connections/:id/activate" do
    it "activates the specified connection" do
      conn1 = user.oauth_connections.create!(provider: 'google_oauth2', uid: '111', active: false)
      conn2 = user.oauth_connections.create!(provider: 'google_oauth2', uid: '222', active: true)

      patch activate_oauth_connection_path(conn1)

      expect(response).to redirect_to(settings_path)
      expect(flash[:notice]).to eq("Switched active Google account.")
      expect(conn1.reload.active).to be true
      expect(conn2.reload.active).to be false
    end
  end

  describe "DELETE /oauth_connections/:id" do
    it "deletes the connection" do
      conn = user.oauth_connections.create!(provider: 'google_oauth2', uid: '111', active: true)

      expect {
        delete oauth_connection_path(conn)
      }.to change(OAuthConnection, :count).by(-1)

      expect(response).to redirect_to(settings_path)
      expect(flash[:notice]).to eq("Disconnected Google account.")
    end

    it "falls back to another connection if the active one is deleted" do
      conn1 = user.oauth_connections.create!(provider: 'google_oauth2', uid: '111', active: true)
      conn2 = user.oauth_connections.create!(provider: 'google_oauth2', uid: '222', active: false)

      delete oauth_connection_path(conn1)

      expect(conn2.reload.active).to be true
    end
  end
end

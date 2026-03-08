require 'rails_helper'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        email: 'test@example.com',
        name: 'Test User',
        image: 'http://example.com/image.jpg'
      },
      credentials: {
        token: 'test_token',
        refresh_token: 'test_refresh_token',
        expires_at: Time.now.to_i + 3600,
        scope: 'email profile'
      }
    })
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  describe "GET /users/auth/google_oauth2/callback" do
    context "when a user is not signed in" do
      it "signs in and redirects a new user" do
        expect {
          post user_google_oauth2_omniauth_callback_path
        }.to change(User, :count).by(1).and change(OAuthConnection, :count).by(1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Successfully authenticated from Google account.")
      end

      it "signs in an existing user with matching email" do
        user = User.create!(email: 'test@example.com', password: 'password123')

        expect {
          post user_google_oauth2_omniauth_callback_path
        }.to change(User, :count).by(0).and change(OAuthConnection, :count).by(1)

        expect(response).to redirect_to(root_path)
      end

      it "signs in an existing user with existing connection" do
        user = User.create!(email: 'other@example.com', password: 'password123')
        connection = user.oauth_connections.create!(provider: 'google_oauth2', uid: '123456789')

        expect {
          post user_google_oauth2_omniauth_callback_path
        }.to change(User, :count).by(0).and change(OAuthConnection, :count).by(0)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when a user is already signed in" do
      let(:user) { User.create!(email: 'signedin@example.com', password: 'password123') }

      before do
        sign_in user
      end

      it "connects the new account and redirects to settings" do
        expect {
          post user_google_oauth2_omniauth_callback_path
        }.to change(OAuthConnection, :count).by(1)

        expect(response).to redirect_to(settings_path)
        expect(flash[:notice]).to eq("Google account connected.")

        connection = OAuthConnection.last
        expect(connection.user).to eq(user)
        expect(connection.email).to eq('test@example.com')
      end

      it "updates an existing connection if re-authenticating" do
        connection = user.oauth_connections.create!(
          provider: 'google_oauth2',
          uid: '123456789',
          access_token: 'old_token'
        )

        expect {
          post user_google_oauth2_omniauth_callback_path
        }.to change(OAuthConnection, :count).by(0)

        expect(response).to redirect_to(settings_path)
        expect(connection.reload.access_token).to eq('test_token')
      end
    end
  end
end

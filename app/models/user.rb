class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :oauth_connections, class_name: "OAuthConnection", dependent: :destroy

  def oauth_connection(provider)
    oauth_connections.find_by(provider: provider.to_s)
  end

  def connect_oauth!(auth)
    connection = oauth_connections.find_or_initialize_by(provider: auth.provider)
    connection.uid = auth.uid
    connection.email = auth.info&.email
    connection.name = auth.info&.name
    connection.image_url = auth.info&.image
    connection.access_token = auth.credentials&.token
    connection.refresh_token = auth.credentials&.refresh_token if auth.credentials&.refresh_token.present?
    connection.expires_at = auth.credentials&.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
    connection.scopes = auth.credentials&.scope
    connection.save!
    connection
  end

  def disconnect_oauth!(provider)
    oauth_connections.find_by(provider: provider.to_s)&.destroy
  end
end

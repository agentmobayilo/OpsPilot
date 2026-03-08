class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :oauth_connections, class_name: "OAuthConnection", dependent: :destroy
  has_one_attached :background_image

  def active_oauth_connection(provider = :google_oauth2)
    scoped = oauth_connections.where(provider: provider.to_s)
    scoped.find_by(active: true) || scoped.order(updated_at: :desc).first
  end

  def connect_oauth!(auth)
    connection = oauth_connections.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    connection.user = self
    connection.email = auth.info&.email
    connection.name = auth.info&.name
    connection.image_url = auth.info&.image
    connection.access_token = auth.credentials&.token
    connection.refresh_token = auth.credentials&.refresh_token if auth.credentials&.refresh_token.present?
    connection.expires_at = auth.credentials&.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
    connection.scopes = auth.credentials&.scope
    connection.active = true
    connection.save!

    GmailSyncJob.perform_later(connection.id)

    oauth_connections.where(provider: auth.provider).where.not(id: connection.id).update_all(active: false)
    connection
  end

  def activate_oauth_connection!(connection)
    oauth_connections.where(provider: connection.provider).update_all(active: false)
    connection.update!(active: true)
  end

  def disconnect_oauth!(connection)
    removed_active = connection.active?
    provider = connection.provider
    connection.destroy!

    if removed_active
      oauth_connections.where(provider: provider).order(updated_at: :desc).first&.update!(active: true)
    end
  end
end

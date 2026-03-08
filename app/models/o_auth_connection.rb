class OAuthConnection < ApplicationRecord
  self.table_name = "oauth_connections"

  encrypts :access_token, :refresh_token

  belongs_to :user
  has_many :email_threads, foreign_key: "oauth_connection_id", dependent: :destroy

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
end

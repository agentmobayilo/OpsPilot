class OAuthConnection < ApplicationRecord
  self.table_name = "oauth_connections"

  encrypts :access_token, :refresh_token

  belongs_to :user

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
end

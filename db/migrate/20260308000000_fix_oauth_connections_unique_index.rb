class FixOauthConnectionsUniqueIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :oauth_connections, [ :user_id, :provider ]
    # The provider+uid index was already added in the previous migration, so we don't need to add it again.
  end
end

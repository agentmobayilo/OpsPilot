class AddActiveToOauthConnections < ActiveRecord::Migration[8.1]
  def change
    add_column :oauth_connections, :active, :boolean, null: false, default: false
    add_index :oauth_connections, [ :user_id, :provider, :active ]
  end
end

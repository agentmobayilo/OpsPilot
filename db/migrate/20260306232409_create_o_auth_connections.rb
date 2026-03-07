class CreateOAuthConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_connections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.string :image_url
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.text :scopes

      t.timestamps
    end

    add_index :oauth_connections, [ :provider, :uid ], unique: true
    add_index :oauth_connections, [ :user_id, :provider ], unique: true
  end
end

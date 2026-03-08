class CreateEmailThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :email_threads do |t|
      t.references :oauth_connection, null: false, foreign_key: true
      t.string :google_id
      t.string :subject
      t.string :snippet
      t.string :classification
      t.string :status
      t.string :history_id

      t.timestamps
    end
    add_index :email_threads, :google_id, unique: true
  end
end

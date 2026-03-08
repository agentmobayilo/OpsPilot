class CreateEmailMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :email_messages do |t|
      t.references :email_thread, null: false, foreign_key: true
      t.string :google_id
      t.string :sender
      t.string :recipient
      t.datetime :date
      t.text :body_text
      t.jsonb :payload

      t.timestamps
    end
    add_index :email_messages, :google_id, unique: true
  end
end

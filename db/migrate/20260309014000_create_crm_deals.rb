class CreateCrmDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :crm_deals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :status
      t.decimal :amount, precision: 10, scale: 2
      t.date :close_date

      t.timestamps
    end
  end
end

class AddUiPrefsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :background_image_url, :string
  end
end

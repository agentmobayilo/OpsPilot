class AddDraftingAndActionToEmailThreads < ActiveRecord::Migration[8.1]
  def change
    add_column :email_threads, :draft_reply, :text
    add_column :email_threads, :action_description, :string
    add_column :email_threads, :action_completed, :boolean
  end
end

class EmailThread < ApplicationRecord
  belongs_to :oauth_connection, class_name: "OAuthConnection"
  has_many :email_messages, dependent: :destroy

  validates :google_id, presence: true, uniqueness: true

  enum :classification, {
    general: "general",
    lead: "lead",
    urgent: "urgent",
    admin: "admin",
    reply: "reply"
  }, default: "general"

  enum :status, {
    pending_classification: "pending_classification",
    classified: "classified",
    drafted: "drafted",
    archived: "archived"
  }, default: "pending_classification"
end

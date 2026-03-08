class EmailMessage < ApplicationRecord
  belongs_to :email_thread

  validates :google_id, presence: true, uniqueness: true
  validates :date, presence: true
end

class CrmDeal < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :status, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end

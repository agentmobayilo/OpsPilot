require 'rails_helper'

RSpec.describe EmailMessage, type: :model do
  describe "associations" do
    it { should belong_to(:email_thread) }
  end

  describe "validations" do
    it "requires a google_id" do
      msg = EmailMessage.new(google_id: nil)
      msg.valid?
      expect(msg.errors[:google_id]).to include("can't be blank")
    end

    it "requires a date" do
      msg = EmailMessage.new(date: nil)
      msg.valid?
      expect(msg.errors[:date]).to include("can't be blank")
    end
  end
end

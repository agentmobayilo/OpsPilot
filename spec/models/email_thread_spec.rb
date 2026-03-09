require 'rails_helper'

RSpec.describe EmailThread, type: :model do
  describe "associations" do
    it { should belong_to(:oauth_connection).class_name("OAuthConnection") }
    it { should have_many(:email_messages).dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:email_thread) }

    it "requires a google_id" do
      thread = EmailThread.new(google_id: nil)
      thread.valid?
      expect(thread.errors[:google_id]).to include("can't be blank")
    end
  end

  describe "enums" do
    it "defines classification enum" do
      should define_enum_for(:classification)
        .with_values(
          general: "general",
          lead: "lead",
          urgent: "urgent",
          admin: "admin",
          reply: "reply"
        )
        .backed_by_column_of_type(:string)
    end

    it "defines status enum" do
      should define_enum_for(:status)
        .with_values(
          pending_classification: "pending_classification",
          classified: "classified",
          drafted: "drafted",
          archived: "archived"
        )
        .backed_by_column_of_type(:string)
    end
  end
end

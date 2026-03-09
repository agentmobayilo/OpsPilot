require 'rails_helper'

RSpec.describe EmailClassifierJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }
    let(:connection) { create(:oauth_connection, user: user) }

    it "classifies as urgent based on subject" do
      thread = EmailThread.create!(oauth_connection: connection, google_id: "1", subject: "Urgent issue")
      EmailClassifierJob.new.perform(thread.id)
      expect(thread.reload.classification).to eq("urgent")
    end

    it "classifies as lead based on snippet" do
      thread = EmailThread.create!(oauth_connection: connection, google_id: "2", snippet: "I am interested in pricing")
      EmailClassifierJob.new.perform(thread.id)
      expect(thread.reload.classification).to eq("lead")
    end

    it "classifies as reply based on subject" do
      thread = EmailThread.create!(oauth_connection: connection, google_id: "3", subject: "re: your message")
      EmailClassifierJob.new.perform(thread.id)
      expect(thread.reload.classification).to eq("reply")
    end

    it "classifies as general by default" do
      thread = EmailThread.create!(oauth_connection: connection, google_id: "4", subject: "Hello there")
      EmailClassifierJob.new.perform(thread.id)
      expect(thread.reload.classification).to eq("general")
    end
  end
end

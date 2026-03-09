require 'rails_helper'
require 'ostruct'

RSpec.describe GmailSyncJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }
    let(:connection) { create(:oauth_connection, user: user, access_token: "token123", active: true) }

    before do
      # Mock the Gmail API client
      @service_mock = instance_double(Google::Apis::GmailV1::GmailService)
      allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(@service_mock)

      auth_client_mock = instance_double(Signet::OAuth2::Client)
      allow(auth_client_mock).to receive(:fetch_access_token!)
      allow(auth_client_mock).to receive(:access_token).and_return("new_token")
      allow(auth_client_mock).to receive(:expires_in).and_return(3600)

      allow_any_instance_of(Google::Apis::GmailV1::GmailService).to receive(:authorization=)

      client_options_mock = OpenStruct.new
      allow(@service_mock).to receive(:client_options).and_return(client_options_mock)
      allow(@service_mock).to receive(:authorization=)
      allow(@service_mock).to receive(:authorization).and_return(auth_client_mock)
    end

    it "fetches threads and creates EmailThread and EmailMessage records" do
      # Stub list_user_threads
      thread_meta = OpenStruct.new(id: "thread_123")
      list_response = OpenStruct.new(threads: [ thread_meta ])
      allow(@service_mock).to receive(:list_user_threads).with('me', q: 'in:inbox', max_results: 10).and_return(list_response)

      # Stub get_user_thread
      header_subject = OpenStruct.new(name: "Subject", value: "Test Email")
      header_from = OpenStruct.new(name: "From", value: "sender@example.com")
      header_to = OpenStruct.new(name: "To", value: "me@example.com")
      header_date = OpenStruct.new(name: "Date", value: Time.current.to_s)

      msg_payload = OpenStruct.new(
        headers: [ header_subject, header_from, header_to, header_date ],
        body: OpenStruct.new(data: "Body text content"),
        parts: []
      )

      msg_data = OpenStruct.new(id: "msg_123", snippet: "Test snippet", payload: msg_payload)
      thread_data = OpenStruct.new(id: "thread_123", history_id: "100", messages: [ msg_data ])

      allow(@service_mock).to receive(:get_user_thread).with('me', "thread_123").and_return(thread_data)

      expect {
        GmailSyncJob.new.perform(connection.id)
      }.to change(EmailThread, :count).by(1).and change(EmailMessage, :count).by(1)

      thread = EmailThread.last
      expect(thread.google_id).to eq("thread_123")
      expect(thread.subject).to eq("Test Email")

      msg = thread.email_messages.first
      expect(msg.google_id).to eq("msg_123")
      expect(msg.sender).to eq("sender@example.com")
      expect(msg.body_text).to eq("Body text content")
    end
  end
end

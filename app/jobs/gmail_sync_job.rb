require "google/apis/gmail_v1"

class GmailSyncJob < ApplicationJob
  queue_as :default

  def perform(oauth_connection_id)
    oauth_connection = OAuthConnection.find(oauth_connection_id)
    return unless oauth_connection.active?

    service = fetch_service(oauth_connection)

    # Fetch recent threads from INBOX
    response = service.list_user_threads("me", q: "in:inbox", max_results: 10)

    return unless response.threads

    response.threads.each do |thread_metadata|
      sync_thread(service, oauth_connection, thread_metadata.id)
    end

    # Schedule the next sync 5 minutes from now to constantly check for new emails.
    GmailSyncJob.set(wait: 5.minutes).perform_later(oauth_connection_id)
  end

  private

  def fetch_service(oauth_connection)
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = "OpsPilot"
    service.authorization = Signet::OAuth2::Client.new(
      access_token: oauth_connection.access_token,
      refresh_token: oauth_connection.refresh_token,
      client_id: ENV.fetch("GOOGLE_CLIENT_ID", nil),
      client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET", nil),
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )

    # Refresh the token if it's expired or about to expire
    if oauth_connection.expires_at.nil? || oauth_connection.expires_at < 5.minutes.from_now
      service.authorization.fetch_access_token!
      oauth_connection.update!(
        access_token: service.authorization.access_token,
        expires_at: Time.current + service.authorization.expires_in.seconds
      )
    end

    service
  end

  def sync_thread(service, oauth_connection, google_thread_id)
    thread_data = service.get_user_thread("me", google_thread_id)

    # Find subject from the first message's headers
    first_message = thread_data.messages.first
    subject_header = first_message.payload.headers.find { |h| h.name.downcase == "subject" }
    subject = subject_header ? subject_header.value : "(No Subject)"

    email_thread = EmailThread.find_or_initialize_by(
      oauth_connection: oauth_connection,
      google_id: thread_data.id
    )

    is_new_thread = email_thread.new_record?

    email_thread.update!(
      subject: subject,
      snippet: thread_data.messages.last.snippet,
      history_id: thread_data.history_id.to_s
    )

    # Sync all messages in the thread
    thread_data.messages.each do |message_data|
      sync_message(email_thread, message_data)
    end

    # Enqueue classification if it's a new thread
    if is_new_thread
      EmailClassifierJob.perform_later(email_thread.id)
    end
  end

  def sync_message(email_thread, message_data)
    # Skip if we already synced this message
    return if EmailMessage.exists?(google_id: message_data.id)

    headers = message_data.payload.headers
    from_header = headers.find { |h| h.name.downcase == "from" }
    to_header = headers.find { |h| h.name.downcase == "to" }

    date_header = headers.find { |h| h.name.downcase == "date" }
    parsed_date = date_header ? Time.zone.parse(date_header.value) : Time.current

    # Try to extract a plain text body
    body_text = extract_body_text(message_data.payload)

    EmailMessage.create!(
      email_thread: email_thread,
      google_id: message_data.id,
      sender: from_header&.value.to_s,
      recipient: to_header&.value.to_s,
      date: parsed_date,
      body_text: body_text
    )
  end

  def extract_body_text(payload)
    if payload.parts.present?
      # Try to find a text/plain part in multipart messages
      text_part = payload.parts.find { |p| p.mime_type == "text/plain" }
      if text_part && text_part.body.data
        return text_part.body.data
      end

      # If no text/plain, try text/html and strip tags? (MVP ignores HTML for now usually or stores it raw)
      html_part = payload.parts.find { |p| p.mime_type == "text/html" }
      if html_part && html_part.body.data
        # basic fallback, a real app would use nokogiri
        return html_part.body.data.gsub(/<\/?[^>]*>/, " ")
      end
    elsif payload.body.data
      return payload.body.data
    end

    "No plain text body found."
  end
end

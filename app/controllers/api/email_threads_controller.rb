module Api
  class EmailThreadsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_email_thread

    def approve_draft
      if @email_thread.draft_reply.blank?
        render json: { error: "No draft reply available" }, status: :unprocessable_entity
        return
      end

      # 1. Fetch user's active Google connection
      connection = current_user.active_oauth_connection(:google_oauth2)
      unless connection
        render json: { error: "No active Google connection" }, status: :unauthorized
        return
      end

      # 2. Get the Gmail service
      service = fetch_service(connection)

      # 3. Get the recipient from the latest email
      latest_message = @email_thread.email_messages.order(date: :desc).first
      recipient = latest_message&.sender || latest_message&.recipient

      # 4. Construct raw RFC 2822 email message
      message = Mail.new do
        to      recipient
        from    connection.email
        subject "Re: #{@email_thread.subject}"
        body    @email_thread.draft_reply
        
        # Proper threading headers
        headers "In-Reply-To" => latest_message&.google_id,
                "References" => latest_message&.google_id
      end

      # 5. Send via Google API
      msg = Google::Apis::GmailV1::Message.new(raw: message.to_s)
      
      begin
        service.send_user_message('me', msg, thread_id: @email_thread.google_id)
        
        @email_thread.update!(
          status: "archived", # Move out of action list
          draft_reply: nil # Clear draft since it's sent
        )
        
        render json: { success: true }
      rescue => e
        Rails.logger.error "Failed to send email: #{e.message}"
        render json: { error: "Failed to send: #{e.message}" }, status: :bad_gateway
      end
    end

    def complete_action
      if @email_thread.update(action_completed: true, status: "archived")
        render json: { success: true }
      else
        render json: { error: "Failed to complete action" }, status: :unprocessable_entity
      end
    end

    private

    def set_email_thread
      @email_thread = EmailThread.joins(:oauth_connection).where(oauth_connections: { user_id: current_user.id }, id: params[:id]).first
      render json: { error: "Not found" }, status: :not_found unless @email_thread
    end

    def fetch_service(oauth_connection)
      service = Google::Apis::GmailV1::GmailService.new
      service.client_options.application_name = 'OpsPilot'
      service.authorization = Signet::OAuth2::Client.new(
        access_token: oauth_connection.access_token,
        refresh_token: oauth_connection.refresh_token,
        client_id: ENV.fetch("GOOGLE_CLIENT_ID", nil),
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET", nil),
        token_credential_uri: 'https://oauth2.googleapis.com/token'
      )
      
      if oauth_connection.expires_at.nil? || oauth_connection.expires_at < 5.minutes.from_now
        service.authorization.fetch_access_token!
        oauth_connection.update!(
          access_token: service.authorization.access_token,
          expires_at: Time.current + service.authorization.expires_in.seconds
        )
      end
  
      service
    end
  end
end

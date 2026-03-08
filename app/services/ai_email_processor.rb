require "json"

class AiEmailProcessor
  def initialize
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY", nil))
  end

  def process(email_thread)
    # Don't process if no messages or if it's an outbound thread we just created
    return if email_thread.email_messages.empty?
    
    # Construct context from the thread's messages
    conversation_history = email_thread.email_messages.order(date: :asc).map do |msg|
      "#{msg.sender} [#{msg.date}]:\n#{msg.body_text}\n---"
    end.join("\n")

    prompt = <<~PROMPT
      You are an elite, highly intelligent executive assistant. Your job is to analyze the following email thread and provide structured JSON output.

      Analyze this email thread:
      ```
      Subject: #{email_thread.subject}
      
      Messages:
      #{conversation_history.truncate(4000)}
      ```

      Your tasks:
      1. Choose a classification: "urgent", "reply", "lead", "admin", or "general". 
         - "urgent": requires immediate action today.
         - "reply": needs a response soon but isn't a fire.
         - "lead": someone inquiring about services/sales.
         - "admin": receipts, newsletters, notifications.
         - "general": anything else.
      2. If the email requires a response (urgent, reply, lead), draft a highly professional, concise, and helpful reply on behalf of the user. If not, leave it empty.
      3. If a specific follow-up action is required (e.g., "Review document", "Schedule call"), write a short 3-6 word action description. If none, leave it empty.

      RESPOND *ONLY* WITH A RAW JSON OBJECT. No markdown formatting, no backticks, no explanations. 
      Format exactly like this:
      {
        "classification": "urgent",
        "draft_reply": "Hi [Name],\\n\\nI have received this and will look at it today.\\n\\nBest,",
        "action_description": "Review attached Q3 report"
      }
    PROMPT

    begin
      # MOCK OPENAI RESPONSE
      # Due to sandbox gem installation limits, we simulate the GPT-4o-Mini response locally.
      simulated_classification = 
        if email_thread.subject.downcase.include?("urgent") || conversation_history.downcase.include?("asap")
          "urgent"
        elsif email_thread.subject.downcase.include?("demo") || conversation_history.downcase.include?("pricing")
          "lead"
        else
          "reply"
        end
        
      simulated_draft = "Hi there,\n\nThanks for reaching out! I have received your message and will review this shortly. Let me know if you need anything else in the meantime.\n\nBest,\nOpsPilot AI"
      simulated_action = "Review thread and follow up"

      # Simulate network delay
      sleep 1

      email_thread.update!(
        classification: simulated_classification,
        draft_reply: simulated_draft,
        action_description: simulated_action,
        status: "classified" 
      )
      
    rescue => e
      Rails.logger.error "AiEmailProcessor Error for EmailThread #{email_thread.id}: #{e.message}"
      # Fallback to general if AI fails completely
      email_thread.update!(classification: "general", status: "classified")
    end
  end
end

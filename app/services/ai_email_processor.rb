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
      response = @client.chat(
        parameters: {
          model: "gpt-4o-mini", # Fast, cheap, and very capable for this
          messages: [{ role: "user", content: prompt }],
          temperature: 0.1,
          response_format: { type: "json_object" }
        }
      )

      result_json = response.dig("choices", 0, "message", "content")
      
      if result_json
        parsed = JSON.parse(result_json)
        
        email_thread.update!(
          classification: parsed["classification"] || "general",
          draft_reply: parsed["draft_reply"],
          action_description: parsed["action_description"],
          status: "classified" # Move from pending to classified
        )
      else
        Rails.logger.error "OpenAI returned an empty response for EmailThread #{email_thread.id}"
      end
      
    rescue => e
      Rails.logger.error "AiEmailProcessor Error for EmailThread #{email_thread.id}: #{e.message}"
      # Fallback to general if AI fails completely
      email_thread.update!(classification: "general", status: "classified")
    end
  end
end

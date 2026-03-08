class EmailClassifierJob < ApplicationJob
  queue_as :default

  def perform(email_thread_id)
    email_thread = EmailThread.find(email_thread_id)
    
    # MVP Stub: Just basic keyword classification locally instead of LLM for now
    subject = email_thread.subject.to_s.downcase
    snippet = email_thread.snippet.to_s.downcase
    
    classification = "general"
    
    if subject.include?("urgent") || snippet.include?("urgent") || subject.include?("asap")
      classification = "urgent"
    elsif subject.include?("demo") || snippet.include?("pricing") || snippet.include?("interested")
      classification = "lead"
    elsif subject.include?("re:")
      classification = "reply"
    elsif email_thread.email_messages.first&.sender&.include?("admin@")
      classification = "admin"
    end
    
    email_thread.update!(
      classification: classification,
      status: "classified"
    )
  end
end

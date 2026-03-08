class EmailClassifierJob < ApplicationJob
  queue_as :default

  def perform(email_thread_id)
    email_thread = EmailThread.find(email_thread_id)
    
    # MVP Stub: Just basic keyword classification locally instead of LLM for now
    AiEmailProcessor.new.process(email_thread)
  end
end

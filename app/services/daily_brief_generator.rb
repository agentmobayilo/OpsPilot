class DailyBriefGenerator
  def initialize(user)
    @user = user
  end

  def generate
    {
      urgent_emails: urgent_emails,
      pending_deals: pending_deals,
      meetings: upcoming_meetings,
      summary: "You have #{urgent_emails.count} urgent emails to address and #{pending_deals.count} deals in active negotiation."
    }
  end

  private

  def urgent_emails
    # Fetch recent urgent and reply-needed emails
    # This assumes email sync and classification jobs have been running
    connection = @user.active_oauth_connection(:google_oauth2)
    return [] unless connection

    connection.email_threads
              .where(classification: ["urgent", "reply"])
              .where("updated_at >= ?", 24.hours.ago)
              .order(updated_at: :desc)
              .limit(5)
  end

  def pending_deals
    # Fetch active deals that need attention
    @user.crm_deals.where(status: ["Negotiation", "Proposal"])
         .order(close_date: :asc)
         .limit(3)
  end

  def upcoming_meetings
    # Mock data for calendar integration (Phase 2 feature)
    [
      { title: "Sync with Acme Corp", time: "10:00 AM", attendees: 3 },
      { title: "Design Review", time: "1:30 PM", attendees: 5 }
    ]
  end
end

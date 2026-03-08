class Avo::Resources::EmailMessage < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email_thread, as: :belongs_to
    field :google_id, as: :text
    field :sender, as: :text
    field :recipient, as: :text
    field :date, as: :date_time
    field :body_text, as: :textarea
    field :payload, as: :code
  end
end

class Avo::Resources::EmailThread < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :oauth_connection, as: :belongs_to
    field :google_id, as: :text
    field :subject, as: :text
    field :snippet, as: :text
    field :classification, as: :text
    field :status, as: :text
    field :history_id, as: :text
  end
end

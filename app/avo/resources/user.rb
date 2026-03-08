class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :background_image_url, as: :text
    field :email, as: :text
    field :admin, as: :boolean
    field :oauth_connections, as: :has_many
  end
end


FactoryBot.define do
  factory :oauth_connection, class: "OAuthConnection" do
    user
    provider { "google_oauth2" }
    sequence(:uid) { |n| "12345#{n}" }
    access_token { "sample_token" }
  end
end

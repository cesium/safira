defmodule SafiraWeb.CORS do
  @domain Application.fetch_env!(:safira, SafiraWeb.CORS)[:domain]

  use Corsica.Router,
    origins: ~r{^https?://#{@domain}},
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource "/*"
  resource "/api/v1/referrals/*", origins: "*"
end

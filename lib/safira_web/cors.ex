defmodule SafiraWeb.CORS do
  use Corsica.Router,
    origins: System.get_env("FRONTEND_URL"),
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource "/*"
  resource "/api/v1/referrals/*", origins: "*"
end

defmodule SafiraWeb.CORS do
  use Corsica.Router,
    origins: [
      "http://#{System.get_env("CORS_DOMAIN")}",
      "https://#{System.get_env("CORS_DOMAIN")}"
    ],
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource "/*"
  resource "/api/v1/referrals/*", origins: "*"
end

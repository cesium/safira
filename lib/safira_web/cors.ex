defmodule SafiraWeb.CORS do
  @moduledoc false
  @domain System.get_env("CORS_DOMAIN")

  use Corsica.Router,
    origins: ~r{^https?://#{@domain}},
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource("/*")
  resource("/api/referrals/*", origins: "*")
end

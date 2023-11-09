defmodule SafiraWeb.CORS do
  @moduledoc false
  @domain System.get_env("CORS_DOMAIN")

  use Corsica.Router,
    origins: ["http://localhost:3000"],
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600

  resource("/*")
  resource("/api/referrals/*", origins: "*")
end

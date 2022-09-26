use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :safira, SafiraWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :safira, Safira.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "safira_test",
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  port: System.get_env("DB_PORT", "5432"),
  hostname: System.get_env("DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

# Fast testing only
config :bcrypt_elixir, :log_rounds, 4

# Guardian config
config :safira, Safira.Guardian,
  issuer: "safira",
  secret_key: "BnJosu+UxrCR70RWM4dhDJz2bH34D+wTbLcu7R9siQWGr8uGmB8k+ClnAEw3EkVQ"

# Bamboo config
config :safira, Safira.Mailer, adapter: Bamboo.TestAdapter

# Env
System.put_env(%{"FROM_EMAIL" => "geral@safira.safira"})
System.put_env(%{"FRONTEND_URL" => "www.safira.safira"})

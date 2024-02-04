# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :safira,
  ecto_repos: [Safira.Repo],
  company_code: System.get_env("DISCORD_COMPANY_CODE"),
  speaker_code: System.get_env("DISCORD_SPEAKER_CODE"),
  staff_code: System.get_env("DISCORD_STAFF_CODE"),
  from_email: System.get_env("FROM_EMAIL") || "test@seium.com",
  from_email_name: System.get_env("FROM_EMAIL_NAME") || "SEI",
  roulette_cost: String.to_integer(System.get_env("ROULETTE_COST") || "20"),
  roulette_tokens_min: String.to_integer(System.get_env("ROULETTE_TOKENS_MIN") || "5"),
  roulette_tokens_max: String.to_integer(System.get_env("ROULETTE_TOKENS_MAX") || "20"),
  token_bonus: String.to_integer(System.get_env("TOKEN_BONUS") || "10"),
  spotlight_duration: String.to_integer(System.get_env("SPOTLIGHT_DURATION") || "20"),
  discord_bot_url: System.get_env("DISCORD_BOT_URL"),
  discord_bot_api_key: System.get_env("DISCORD_BOT_API_KEY"),
  discord_invite_url: System.get_env("DISCORD_INVITE_URL"),
  max_cv_file_size: String.to_integer(System.get_env("MAX_CV_SIZE") || "8000000")

# Configures the endpoint
config :safira, SafiraWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3KpMz5Dsmzm2+40c8Urp8UC0N95fFWvsHudtIUHjTv2yGsikjN3wIHPNPi3e+4xi",
  render_errors: [view: SafiraWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: Safira.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Guardian config
config :safira, Safira.Guardian,
  issuer: "safira",
  secret_key: System.get_env("GUARDIAN_SECRET")

# AWS config
config :arc,
  bucket: {:system, "S3_BUCKET"},
  virtual_host: true

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: System.get_env("AWS_REGION"),
  s3: [
    scheme: "https://",
    host: "s3.#{System.get_env("AWS_REGION")}.amazonaws.com",
    region: System.get_env("AWS_REGION")
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :torch,
  otp_app: :safira,
  template_format: "eex"

config :safira, :pow,
  user: Safira.Admin.Accounts.AdminUser,
  repo: Safira.Repo,
  web_module: SafiraWeb

config :http_stream, adapter: HTTPStream.Adapter.HTTPoison

config :safira, Safira.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: {:system, "MAILGUN_API_KEY"},
  domain: {:system, "MAILGUN_DOMAIN"},
  base_uri: {:system, "MAILGUN_BASE_URL"},
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Cron-like jobs
config :quantum, Safira.JobScheduler, timezone: "Europe/Lisbon"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

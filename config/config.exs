# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :safira,
  ecto_repos: [Safira.Repo],
  company_code: System.get_env("COMPANY_CODE"),
  speaker_code: System.get_env("SPEAKER_CODE"),
  staff_code: System.get_env("STAFF_CODE")

# Configures the endpoint
config :safira, SafiraWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3KpMz5Dsmzm2+40c8Urp8UC0N95fFWvsHudtIUHjTv2yGsikjN3wIHPNPi3e+4xi",
  render_errors: [view: SafiraWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Safira.PubSub,
           adapter: Phoenix.PubSub.PG2]

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :safira,
  ecto_repos: [Safira.Repo]

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
  s3: [
    scheme: "https://",
    host: "#{System.get_env("S3_BUCKET")}.s3.amazonaws.com/#{System.get_env("S3_BUCKET")}",
    region: System.get_env("AWS_REGION")
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

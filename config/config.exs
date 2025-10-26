# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :safira,
  ecto_repos: [Safira.Repo],
  generators: [timestamp_type: :utc_datetime],
  build_env: Mix.env()

# Flop configuration
config :flop,
  repo: Safira.Repo

# Waffle configuration
config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv",
  asset_host: {:system, "ASSET_HOST"}

# Configures the endpoint
config :safira, SafiraWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SafiraWeb.ErrorHTML, json: SafiraWeb.ErrorJSON],
    layout: {SafiraWeb.Layouts, :root}
  ],
  pubsub_server: Safira.PubSub,
  live_view: [signing_salt: "TzWGKiXG"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :safira, Safira.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  safira: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  safira: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure oban job processing
config :safira, Oban,
  engine: Oban.Engines.Basic,
  repo: Safira.Repo,
  queues: [
    badge_conditions: 10,
    badge_triggers: 10
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

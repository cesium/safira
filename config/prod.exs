import Config

config :logger, :console, format: "[$level] $message\n"

config :waffle,
  storage: Waffle.Storage.S3,
  bucket: {:system, "AWS_S3_BUCKET"},
  asset_host: {:system, "ASSET_HOST"}

config :ex_aws,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  region: {:system, "AWS_REGION"},
  s3: [
    scheme: "https://",
    host: {:system, "ASSET_HOST"},
    region: {:system, "AWS_REGION"},
    access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
    secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}
  ]

config :swoosh, :api_client, Swoosh.ApiClient.Hackney

config :safira, Safira.Mailer, adapter: Swoosh.Adapters.ExAwsAmazonSES

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
config :safira, Safira.Endpoint,
  url: [scheme: "https", host: System.get_env("PHX_HOST") || "stg.seium.org", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

defmodule Safira.Repo do
  use Ecto.Repo,
    otp_app: :safira,
    adapter: Ecto.Adapters.Postgres
end

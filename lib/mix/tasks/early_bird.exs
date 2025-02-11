defmodule Mix.Tasks.EarlyBird do
  @moduledoc """
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Repo

  def run(_args) do
    Mix.Task.run("app.start")

    attendees =
      Attendee
      |> order_by([a], a.inserted_at)
      |> where([a], not a.ineligible)
      |> limit(50)
      |> preload(:user)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Early Bird")

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.EarlyBird.run([])

defmodule Mix.Tasks.GoldMine do
  @moduledoc """
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Contest.BadgeRedeem
  alias Safira.Repo

  def run(_args) do
    Mix.Task.run("app.start")

    golds = ["Accenture", "Retail Consult", "Uphold"]

    len = Kernel.length(golds)

    attendees =
      BadgeRedeem
      |> join(:inner, [br], a in Attendee, on: br.attendee_id == a.id)
      |> join(:inner, [br, a], b in Badge, on: br.badge_id == b.id)
      |> where([br, a, b], b.name in ^golds)
      |> group_by([br, a, b], a.id)
      |> having([br, a, b], count(br.id) == ^len)
      |> select([br, a, b], a)
      |> subquery()
      |> preload(:user)
      |> Repo.all()

    badge = Repo.one(from b in Badge, where: b.name == "Gold Mine")

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.GoldMine.run([])

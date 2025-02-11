defmodule Mix.Tasks.FirstComeFirstServed do
  @moduledoc """
  """
  use Mix.Task
  import Ecto.Query, warn: false

  alias Safira.Accounts
  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Contest.BadgeRedeem
  alias Safira.Repo

  def run(_args) do
    Mix.Task.run("app.start")

    attendees =
      BadgeRedeem
      |> join(:inner, [br], a in Attendee, on: br.attendee_id == a.id)
      |> join(:inner, [br, a], b in Badge, on: br.badge_id == b.id)
      |> where([br, a, b], b.name == "Acreditação")
      |> order_by([br, a, b], br.inserted_at)
      |> where([br, a, b], not a.ineligible)
      |> limit(50)
      |> preload(attendee: [:user])
      |> Repo.all()
      |> Enum.map(fn br -> br.attendee end)

    badge = Repo.one(from b in Badge, where: b.name == "First Come, First Served")

    for attendee <- attendees do
      Mix.shell().info("Processing #{attendee.user.name}")

      case Contest.redeem_badge(badge, attendee) do
        {:ok, _} -> Mix.shell().info("Badge redeemed for #{attendee.user.name}")
        {:error, _} -> Mix.shell().info("Badge redeem failed for #{attendee.user.name}")
      end
    end
  end
end

Mix.Tasks.FirstComeFirstServed.run([])

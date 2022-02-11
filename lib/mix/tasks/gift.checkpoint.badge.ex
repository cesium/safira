defmodule Mix.Tasks.Gift.Company.Checkpoint.Badge do
  use Mix.Task

  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest.Badge
  alias Safira.Contest.Redeem

  alias Safira.Repo
  alias Ecto.Multi
  alias Ecto.Multi

  @shortdoc "Gives checkpoint badge to attendees that reach that checkpoint"

  @moduledoc """
    This task needs to receive:
      - badge_id: Badge's ID to give
      - badge_count: Number of Badges thar an attendee must have
          to receive the checkpoint basge
      - entries: Number of entries that an attendee receives for
          having this badge
      - badge_type: type of badge to confirm
  """

  def run(args) do
    cond do
      length(args) != 4 ->
        Mix.shell().info("Needs to receive badge_id, badge_count, entries and badge_type.")

      true ->
        args |> create()
    end
  end

  defp create(args) do
    Mix.Task.run("app.start")

    args
    |> validate_args()
    |> map_args()
    |> gift()
  end

  defp validate_args(args) do
    try do
      args
    |> Enum.map(fn x -> Integer.parse(x) |> elem(0) end)
    rescue
      ArgumentError ->
        Mix.shell().info("All arguments should be integers")
    end
  end

  defp map_args(args) do
    %{
      badge_id: Enum.at(args, 0),
      badge_count: Enum.at(args, 1),
      entries: Enum.at(args, 2),
      badge_type: Enum.at(args, 3),
    }
  end

  defp gift(args) do
    case Repo.get(Badge, Map.get(args, :badge_id)) do
      %Badge{} = badge ->
        args = Map.put(args, :badge, badge)
        attendees = get_attendees_company_badges(args)
        give_checkpoint_badge(args, attendees)

      nil ->
        Mix.shell().error("Badge_id needs to be valid.")
    end
  end

  defp get_attendees_company_badges(args) do
    Repo.all(
      from a in Attendee,
      join: r in Redeem, on: a.id == r.attendee_id,
      join: b in Badge, on: r.badge_id == b.id,
      where: b.type == ^Map.get(args, :badge_type),
      preload: [badges: b]
    )
    |> Enum.map(fn a -> Map.put(a, :badge_count, length(a.badges)) end)
    |> Enum.filter(fn x -> x.badge_count >= Map.get(args, :badge_count) end)
  end

  defp give_checkpoint_badge(args, attendees) do
    attendees
    |> Enum.each(fn a ->
      %{
        attendee_id: a.id,
        badge_id: Map.get(args, :badge_id),
        manager_id: 1
      }
      |> create_redeem(args, a, Map.get(args, :badge))
    end)
  end

  defp create_redeem(redeem_attrs, args, attendee, badge) do
    Multi.new()
    |> Multi.insert(:redeem, Redeem.changeset(%Redeem{}, redeem_attrs, :admin))
    |> Multi.update(:attendee,
      Attendee.update_on_redeem_changeset(
        attendee,
        %{
          token_balance: attendee.token_balance + badge.tokens,
          entries: attendee.entries + Map.get(args, :entries)
        }
      )
    )
    |> Repo.transaction()
  end

end

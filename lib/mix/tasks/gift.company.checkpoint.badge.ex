defmodule Mix.Tasks.Gift.Company.Checkpoint.Badge do
  use Mix.Task

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
  """

  def run(args) do
    cond do
      length(args) != 3 ->
        Mix.shell().info("Needs to receive badge_id, badge_count and entries.")

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
    |> IO.inspect()
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
      entries: Enum.at(args, 2)
    }
  end

  defp gift(args) do
    case Repo.get(Badge, Map.get(args, :badge_id)) do
      %Badge{} = badge ->
        Map.put(args, :badge_id, badge)

      nil ->
        Mix.shell().error("Badge_id needs to be valid.")
    end
  end

  defp create_redeem(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:redeem, Redeem.changeset(%Redeem{}, attrs))
    |> Multi.update(:attendee, fn %{redeem: redeem} ->
      redeem = Repo.preload(redeem, [:badge, :attendee])

      Changeset.change(redeem.attendee,
        token_balance: redeem.attendee.token_balance + redeem.badge.tokens
      )
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, Map.get(result, :redeem)}
      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

end

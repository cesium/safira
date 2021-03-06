defmodule Mix.Tasks.Gift.Daily.Badge do
  use Mix.Task

  import Ecto.Query, warn: false

  alias Safira.Accounts.Attendee
  alias Safira.Contest
  alias Safira.Contest.Redeem
  alias Safira.Contest.Badge

  alias Safira.Repo

  # Expects a date in yyyy-mm-dd format
  def run(args) do
    Mix.Task.run("app.start")

    cond do
      length(args) != 2 ->
        Mix.shell().info("Needs to receive badge_id and the date of the day.")

      true ->
        args |> create()
    end
  end

  def create(args) do

    {badge_id, date} = {args |> Enum.at(0), args |> Enum.at(1) |>  Date.from_iso8601!()}

    Repo.all(
      from a in Attendee,
        join: r in Redeem, on: a.id == r.attendee_id,
        join: b in Badge, on: r.badge_id == b.id,
        where: not(is_nil a.user_id) and fragment("?::date", r.inserted_at) == ^date,
        preload: [badges: b]
    )
    |> Enum.map(fn a -> Map.put(a, :badge_count, length(a.badges)) end)
    |> Enum.filter(fn a -> a.badge_count > 0 end)
    |> Enum.each(fn a ->
      Contest.create_redeem(%{
        attendee_id: a.id,
        manager_id: 1,
        badge_id: badge_id
      })
    end)

  end

end

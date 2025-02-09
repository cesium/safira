defmodule Safira.Repo.Seeds.Prizes do
  alias Safira.{Contest, Event, Minigames, Repo}

  @prizes File.read!("priv/fake/prizes.txt") |> String.split("\n")

  def run do
    case Minigames.list_prizes() do
      [] ->
        seed_prizes()
      _  ->
        Mix.shell().error("Found prizes, aborting seeding prizes.")
    end

    case Contest.list_daily_prizes() do
      [] ->
        seed_daily_prizes()
      _  ->
        Mix.shell().error("Found daily prizes, aborting seeding daily prizes.")
    end
  end

  defp seed_prizes do
    for name <- @prizes do
      prize_seed = %{
        name: name,
        stock: Enum.random([10, 20, 30, 40, 50]),
      }

      changeset = Minigames.Prize.changeset(%Minigames.Prize{}, prize_seed)

      case Repo.insert(changeset) do
        {:ok, _} -> :ok
        {:error, changeset} ->
          Mix.shell().error("Failed to insert prize: #{prize_seed.name}")
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

    def seed_daily_prizes do
      prizes = Repo.all(Minigames.Prize)

      start_date = Timex.DateTime.new!(Event.get_event_start_date(), Timex.Time.new!(9, 0, 0))

      days = 0..3
           |> Enum.map(fn offset -> start_date |> DateTime.add(offset, :day) |> DateTime.to_date() end)

      for d <- [nil | days] do
        for p <- 1..3 do
          attrs = %{
            date: d,
            prize_id: Enum.random(prizes).id,
            place: p
          }

          changeset = Contest.DailyPrize.changeset(%Contest.DailyPrize{}, attrs)

          case Repo.insert(changeset) do
            {:ok, _} -> :ok
            {:error, changeset} ->
              Mix.shell().error("Failed to insert daily prize")
              Mix.shell().error(Kernel.inspect(changeset.errors))
          end
        end
      end
    end
  end

Safira.Repo.Seeds.Prizes.run()

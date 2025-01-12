defmodule Safira.Repo.Seeds.Minigames do
  alias Safira.Minigames
  alias Safira.Repo

  @prizes File.read!("priv/fake/prizes.txt") |> String.split("\n")
  @challenges File.read!("priv/fake/challenges.txt") |> String.split("\n")

  def run do
    case Minigames.list_prizes() do
      [] ->
        seed_prizes()
      _  ->
        Mix.shell().error("Found prizes, aborting seeding prizes.")
    end

    case Minigames.list_challenges() do
      [] ->
        seed_challenges()
      _ ->
        Mix.shell().error("Found challenges, aborting seeding challenges.")
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

  defp seed_challenges do
    for {challenge, i} <- Enum.with_index(@challenges) do
      [name, description, type, date_str] = String.split(challenge, ";")

      date = if date_str == "", do: nil, else: Date.from_iso8601!(date_str)

      {:ok, challenge} = Minigames.create_challenge(%{
        name: name,
        description: description,
        type: String.to_atom(type),
        date: date,
        display_priority: i
      })

      prize_count = Enum.random(1..3)

      for i <- 1..prize_count do
        prize = Minigames.list_prizes() |> Enum.random()

        Minigames.create_challenge_prize(%{prize_id: prize.id, challenge_id: challenge.id, place: i})
      end
    end
  end
end

Safira.Repo.Seeds.Minigames.run()

defmodule Safira.Repo.Seeds.Prizes do
  alias Safira.Minigames
  alias Safira.Repo

  @prizes File.read!("priv/fake/prizes.txt") |> String.split("\n")

  def run do
    case Minigames.list_prizes() do
      [] ->
        seed_prizes()
      _  ->
        Mix.shell().error("Found prizes, aborting seeding prizes.")
    end
  end

  def seed_prizes do
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
end

Safira.Repo.Seeds.Prizes.run()

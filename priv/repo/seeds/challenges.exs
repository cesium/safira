defmodule Safira.Repo.Seeds.Challenges do
  alias Safira.Challenges
  alias Safira.Minigames

  @challenges File.read!("priv/fake/challenges.txt") |> String.split("\n")

  def run do
    case Challenges.list_challenges() do
      [] ->
        seed_challenges()
      _ ->
        Mix.shell().error("Found challenges, aborting seeding challenges.")
    end
  end

  defp seed_challenges do
    for {challenge, i} <- Enum.with_index(@challenges) do
      [name, description, type, date_str] = String.split(challenge, ";")

      date = if date_str == "", do: nil, else: Date.from_iso8601!(date_str)

      {:ok, challenge} = Challenges.create_challenge(%{
        name: name,
        description: description,
        type: String.to_atom(type),
        date: date,
        display_priority: i
      })

      prize_count = Enum.random(1..3)

      for i <- 1..prize_count do
        prize = Minigames.list_prizes() |> Enum.random()

        Challenges.create_challenge_prize(%{prize_id: prize.id, challenge_id: challenge.id, place: i})
      end
    end
  end
end

Safira.Repo.Seeds.Challenges.run()

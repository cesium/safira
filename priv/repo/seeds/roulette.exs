defmodule Safira.Repo.Seeds.Roulette do
  @moduledoc false

  alias Mix.Tasks.Gen.Prizes
  alias Safira.Accounts.Attendee
  alias Safira.Repo
  alias Safira.Roulette

  @number_spins 40

  def run do
    seed_prizes()
    seed_spins()
  end

  defp seed_prizes do
    Prizes.run(["data/wheel.csv"])
  end

  defp seed_spins do
    attendees = Repo.all(Attendee)
    for _ <- 0..@number_spins do
      at = Enum.random(attendees)

      # Making sure attendee has enough tokens to spin the wheel
      at = at
      |> Attendee.update_token_balance_changeset(
        %{token_balance: at.token_balance + Application.fetch_env!(:safira, :roulette_cost)})
      |> Repo.update!()

      Roulette.spin_transaction(at)
    end
  end
end

Safira.Repo.Seeds.Roulette.run()

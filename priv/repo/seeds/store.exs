defmodule Safira.Repo.Seeds.Store do
  @moduledoc false

  alias Mix.Tasks.Gen.Redeemables
  alias Safira.Accounts.Attendee
  alias Safira.Repo
  alias Safira.Store
  alias Safira.Store.Redeemable

  @buys_amount 30

  def run do
    seed_redeemables()
    seed_buys()
  end

  defp seed_redeemables do
    Redeemables.run(["data/redeemables/redeemables.csv"])
  end

  defp seed_buys do
    attendees = Repo.all(Attendee)
    redeemables = Repo.all(Redeemable)

    for i <- 0..@buys_amount, do: buy_random(redeemables, attendees)
  end

  defp buy_random(redeemables, attendees) do
      # By making this random there is the possibility this fails if the same
      # product is picked so much it runs out of stock. However this is not
      # a problem, as long as the script continues running, we will just
      # have fewer purchases
      at = Enum.random(attendees)
      r  = Enum.random(redeemables)

      amount = Enum.random(1..r.max_per_user)
      redeemed = Enum.random([true, false])

      # Making sure attendee has enough tokens to purchase
      at
      |> Attendee.update_token_balance_changeset(%{token_balance: at.token_balance + amount * r.price})
      |> Repo.update!()

      for j <- 0..amount, do: Store.buy_redeemable(r.id, at)

      if redeemed do
        Store.redeem_redeemable(r.id, at, amount)
      end
  end
end

Safira.Repo.Seeds.Store.run()

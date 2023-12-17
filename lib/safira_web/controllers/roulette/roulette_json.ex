defmodule SafiraWeb.RouletteJSON do
  @moduledoc false

  alias SafiraWeb.BadgeJSON
  alias SafiraWeb.PrizeJSON

  def roulette(changes) do
    prize = Map.get(changes, :prize)
    attendee = Map.get(changes, :attendee)
    attendee_token_balance = Map.get(changes, :attendee_token_balance)
    attendee_entries = Map.get(changes, :attendee_entries)
    badge = Map.get(changes, :badge)

    resp = %{
      prize: PrizeJSON.prize(%{prize: prize})
    }

    resp =
      cond do
        not is_nil(attendee_token_balance) ->
          Map.put(resp, :tokens, attendee_token_balance.token_balance - attendee.token_balance)

        not is_nil(attendee_entries) ->
          Map.put(resp, :entries, 1)

        not is_nil(badge) ->
          Map.put(resp, :badge, BadgeJSON.badge(badge))

        true ->
          resp
      end

    resp
  end

  def price_show(%{price: price}) do
    %{price: price}
  end

  def latest_prizes(%{latest_prizes: latest_prizes}) do
    %{data: for(p <- latest_prizes, do: latest_prize_show(%{roulette: p}))}
  end

  def latest_prize_show(%{roulette: latest_prize}) do
    %{
      attendee_name: elem(latest_prize, 0),
      prize: PrizeJSON.prize_show(%{prize: elem(latest_prize, 1)}),
      date: elem(latest_prize, 2)
    }
  end
end

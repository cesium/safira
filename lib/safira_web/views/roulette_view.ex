defmodule SafiraWeb.RouletteView do
  use SafiraWeb, :view

  def render("roulette.json", changes) do
    prize = Map.get(changes, :prize)
    attendee = Map.get(changes, :attendee)
    attendee_token_balance = Map.get(changes, :attendee_token_balance)
    attendee_entries = Map.get(changes, :attendee_entries)
    badge = Map.get(changes, :badge)

    resp = %{
      prize: render_one(prize, SafiraWeb.PrizeView, "prize.json")
    }

    resp =
    cond do
      not is_nil attendee_token_balance ->
        Map.put(resp, :tokens, (attendee_token_balance.token_balance - attendee.token_balance))

      not is_nil attendee_entries ->
        Map.put(resp, :entries, 1)

      not is_nil badge ->
        Map.put(resp, :badge, render_one(badge, SafiraWeb.BadgeView, "badge.json"))

      true ->
        resp
    end

    resp
  end

  def render("latest_prizes.json", %{latest_prizes: latest_prizes}) do
    %{data: render_many(latest_prizes, SafiraWeb.RouletteView, "latest_prize_show.json")}
  end

  def render("latest_prize_show.json", %{roulette: latest_prize}) do
    %{
      attendee_name: elem(latest_prize, 0),
      prize: render_one(elem(latest_prize, 1), SafiraWeb.PrizeView, "prize_show.json"),
      date: elem(latest_prize, 2)
    }
  end
end

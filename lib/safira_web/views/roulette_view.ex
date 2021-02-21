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

  def render("latest_prizes.json", %{prizes: prizes}) do
    %{data: render_many(prizes, SafiraWeb.PrizeView, "prize_show.json")}
  end
end

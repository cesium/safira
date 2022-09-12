defmodule SafiraWeb.BonusView do
  use SafiraWeb, :view

  def render("bonus.json", changes) do
    attendee = Map.get(changes, :update_attendee)
    bonus = Map.get(changes, :upsert_bonus)

    value = %{
      name: attendee.name,
      attendee_id: attendee.id,
      token_bonus: Application.fetch_env!(:safira, :token_bonus),
      bonus_count: bonus.count,
      company_id: bonus.company_id
    }

    IO.inspect(value)

    value
  end
end

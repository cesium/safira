defmodule SafiraWeb.BonusView do
  use SafiraWeb, :view

  @token_bonus Application.compile_env!(:safira, :token_bonus)

  def render("bonus.json", changes) do
    attendee = Map.get(changes, :update_attendee)
    bonus = Map.get(changes, :upsert_bonus)

    %{
      name: attendee.name,
      attendee_id: attendee.id,
      token_bonus: @token_bonus,
      bonus_count: bonus.count,
      company_id: bonus.company_id
    }
  end
end

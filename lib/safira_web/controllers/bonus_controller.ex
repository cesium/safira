defmodule SafiraWeb.BonusController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Interaction

  action_fallback SafiraWeb.FallbackController

  def give_bonus(conn, %{"id" => attendee_id}) do
    user = Accounts.get_user(conn)
    attendee = Accounts.get_attendee(attendee_id)

    cond do
      Accounts.is_company(conn) && !is_nil(attendee) ->
        company = user |> Map.fetch!(:company)

        with {:ok, changes} <- Interaction.give_bonus(attendee, company) do
          render(conn, "bonus.json", changes)
        end

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
        |> halt()
    end
  end
end

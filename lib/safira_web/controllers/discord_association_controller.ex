defmodule SafiraWeb.DiscordAssociationController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.Attendee

  action_fallback SafiraWeb.FallbackController

  # association_params= %{"discord_association_code" => discord_association_code, "discord_id" => discord_id}
  def create(conn, association_params) do
    cond do
      Accounts.is_manager(conn) ->
        association_aux(conn, association_params)

      true ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Cannot access resource"})
        |> halt()
    end
  end

  defp association_aux(conn, %{
         "discord_association_code" => discord_association_code,
         "discord_id" => discord_id
       }) do
    attendee = Accounts.get_attendee_by_discord_association_code(discord_association_code)

    cond do
      not is_nil(attendee) ->
        # no need for checking if discord_id is valid
        # since the the user's discord_id is obtained by the bot through the discord API
        Accounts.update_attendee_association(attendee, %{discord_id: discord_id})

        conn
        |> put_status(:created)
        |> json(%{association: "Attendee discord_id successfully associated"})

      true ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Attendee not found"})
    end
  end
end

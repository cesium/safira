defmodule SafiraWeb.DiscordAssociationController do
  use SafiraWeb, controller: "1.6"

  alias Safira.Accounts

  action_fallback SafiraWeb.FallbackController

  def show(conn, %{"id" => discord_id}) do
    if Accounts.is_company(conn) || Accounts.is_staff(conn) do
      show_aux(conn, discord_id)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end

  # association_params= %{"discord_association_code" => discord_association_code, "discord_id" => discord_id}
  def create(conn, association_params) do
    if Accounts.is_staff(conn) do
      association_aux(conn, association_params)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Cannot access resource"})
      |> halt()
    end
  end

  defp show_aux(conn, discord_id) do
    attendee = Accounts.get_attendee_by_discord_id(discord_id)

    if is_nil(attendee) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "No attendee with that discord_id"})
    else
      conn
      |> put_status(:ok)
      |> json(%{id: attendee.id})
    end
  end

  defp association_aux(
         conn,
         %{
           "discord_association_code" => discord_association_code,
           "discord_id" => _discord_id
         } = association_params
       ) do
    company_code = Application.fetch_env!(:safira, :company_code)
    staff_code = Application.fetch_env!(:safira, :staff_code)
    speaker_code = Application.fetch_env!(:safira, :speaker_code)

    case discord_association_code do
      ^company_code -> notify_succesful_association(conn, "empresa")
      ^staff_code -> notify_succesful_association(conn, "staff")
      ^speaker_code -> notify_succesful_association(conn, "orador")
      _ -> associate_attendee(conn, association_params)
    end
  end

  defp associate_attendee(conn, %{
         "discord_association_code" => discord_association_code,
         "discord_id" => discord_id
       }) do
    attendee = Accounts.get_attendee_by_discord_association_code(discord_association_code)

    if is_nil(attendee) do
      conn
      |> put_status(:not_found)
      |> json(%{error: "Unable to associate"})
    else
      # no need for checking if discord_id is valid
      # since the the user's discord_id is obtained by the bot through the discord API
      Accounts.update_attendee_association(attendee, %{discord_id: discord_id})
      notify_succesful_association(conn, "participante")
    end
  end

  defp notify_succesful_association(conn, role) do
    conn
    |> put_status(:created)
    |> json(%{association: role})
  end
end

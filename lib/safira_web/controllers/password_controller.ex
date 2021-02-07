defmodule SafiraWeb.PasswordController do
  use SafiraWeb, :controller

  alias Safira.Accounts
  alias Safira.Accounts.User
  alias Safira.Auth
  alias Safira.Repo

  def create(conn, %{"user" => pw_params}) do
    email = pw_params["email"]
    user = case email do
      nil ->
        nil
      email ->
        Accounts.get_user_email(email)
    end

    case user do
      nil ->
        conn
        |> put_status(:created)
        |> render("show.json", %{})
      user ->
        user = Auth.reset_password_token(user)
        # send password token to pw_params["email"]
        Safira.Email.send_reset_email(email, user.reset_password_token)

        conn
        |> put_status(:created)
        |> render("show.json", %{})
    end
  end

  def update(conn, %{"id" => token, "user" => pw_params}) do
    user = Accounts.get_user_token(token)
    case user do
      nil ->
        conn
          |> put_status(:bad_request)
          |> render("error.json", error: "Password reset token nonexistent.")
      user ->
        if Auth.expired?(user.reset_token_sent_at) do
          User.password_token_changeset(user, %{
            reset_password_token: nil,
            reset_token_sent_at: nil
          })
          |> Repo.update!

          conn
          |> put_status(:bad_request)
          |> render("error.json", error: "Password reset token expired.")
        else
          changeset = User.update_password_changeset(user, pw_params)
          case Repo.update(changeset) do
            {:ok, _user} ->
              User.password_token_changeset(user, %{
                reset_password_token: nil,
                reset_token_sent_at: nil
              })
              |> Repo.update!

              conn
              |> put_status(:ok)
              |> render("ok.json", %{})
            {:error, _changeset} ->
              conn
              |> put_status(:bad_request)
              |> render("error.json", error: "Something went wrong.")
          end
        end
    end
  end
end

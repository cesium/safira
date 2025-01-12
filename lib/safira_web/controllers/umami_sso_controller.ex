defmodule SafiraWeb.Backoffice.UmamiSSOController do
  use SafiraWeb, :controller

  @api_token_request_route "/api/auth/login"

  def sso_redirect(conn, _params) do
    # TODO: Validate if the user is authorized to access this page

    url = Application.get_env(:safira, :umami_instance_url) |> IO.inspect()
    user = Application.get_env(:safira, :umami_guest_user_name)
    password = Application.get_env(:safira, :umami_guest_user_password)

    # Request a token to the API
    request_sso_token(url, user, password)
  end

  defp request_sso_token(url, user, password) do
    Finch.build(:post, url <> @api_token_request_route, [], sso_request_body(user, password))
    |> IO.inspect()
    |> Finch.request(Safira.Finch)
    |> IO.inspect()
  end

  defp sso_request_body(user, password) do
    %{
      "username" => user,
      "password" => password
    }
    |> Jason.encode_to_iodata!()
  end
end

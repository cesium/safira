defmodule SafiraWeb.PasswordView do
  use SafiraWeb, :view

  def render("show.json", %{}) do
    %{
      data: %{
        attributes: %{
          info:
            "If your email address exists in our database, you will receive a password reset link at your email address."
        }
      }
    }
  end

  def render("ok.json", %{}) do
    %{data: %{attributes: %{info: "User password successfully updated."}}}
  end

  def render("error.json", %{error: error}) do
    %{errors: [%{detail: error}]}
  end
end

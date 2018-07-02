defmodule SafiraWeb.AuthView do
  use SafiraWeb, :view

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end

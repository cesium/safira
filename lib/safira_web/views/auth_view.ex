defmodule SafiraWeb.AuthView do
  use SafiraWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end
  
  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end

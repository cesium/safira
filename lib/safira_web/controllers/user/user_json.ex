defmodule SafiraWeb.UserJSON do
  @moduledoc false

  def index(%{users: users}) do
    %{data: for(u <- users, do: data(u))}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  def data(%{user: user}) do
    %{id: user.id, email: user.email}
  end
end

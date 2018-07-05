defmodule Safira.Contest do

  import Ecto.Query, warn: false
  alias Safira.Repo

  alias Safira.Contest.Badge

  def list_badges do
    Repo.all(Badge)
  end

  def get_badge!(id), do: Repo.get!(Badge, id)

  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end
end

defmodule Safira.Spotlight do
  def list_spotlight do
    Spotlight
    |> Repo.all()
  end

  def get_spotlight!(id), do: Repo.get!(Spotlight, id)
end

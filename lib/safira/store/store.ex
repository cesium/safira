defmodule Safira.Store do
  import Ecto.Query, warn: false
  alias Safira.Repo
  alias Safira.Store.Redeemable

  def list_redeemables do
    Repo.all(Redeemable)
  end

  def get_redeemable!(id), do: Repo.get!(Redeemable, id)

  def create_redeemable(attrs \\ %{}) do
    %Redeemable{}
    |> Redeemable.changeset(attrs)
    |> Repo.insert()
  end
end

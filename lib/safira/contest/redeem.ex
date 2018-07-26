defmodule Safira.Contest.Redeem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "redeems" do

    timestamps()
  end

  @doc false
  def changeset(redeem, attrs) do
    redeem
    |> cast(attrs, [])
    |> validate_required([])
  end
end

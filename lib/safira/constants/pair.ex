defmodule Safira.Constants.Pair do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:key, :string, []}
  schema "constants" do
    field :value, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pair, attrs) do
    pair
    |> cast(attrs, [:key, :value])
    |> validate_required([:key])
    |> unique_constraint(:key)
  end
end

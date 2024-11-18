defmodule Safira.Spotlights do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spotlights" do
    field :duration, :integer
  end

  def change_spotlight(spotlight, attrs \\ %{}) do
    spotlight
    |> cast(attrs, [:duration])
    |> validate_required([:duration])
  end
end

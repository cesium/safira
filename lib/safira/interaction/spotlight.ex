defmodule Safira.Interaction.Spotlight do
  @moduledoc """
  Spotlight was a feature that would highlight a company
  for a given amount of time in discord
  (Deprecated, used for online SEI)
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "spotlights" do
    field :active, :boolean, default: false
    field :badge_id, :id
    field :lock_version, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, [:active, :badge_id])
    |> validate_required([:active, :badge_id])
    |> validate_not_already_active()
    |> Ecto.Changeset.optimistic_lock(:lock_version)
  end

  def finish_changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, [:active])
    |> validate_required([:active])
  end

  defp validate_not_already_active(changeset) do
    if changeset.data && changeset.data.active do
      add_error(changeset, :active, "Another spotlight is still active")
    else
      changeset
    end
  end
end

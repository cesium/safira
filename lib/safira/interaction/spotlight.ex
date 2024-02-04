defmodule Safira.Interaction.Spotlight do
  @moduledoc """
  Spotlight allows companies to highlight a badge for a period of time,
  giving more tokens to attendees who redeem it.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Safira.Interaction

  schema "spotlights" do
    field :end, :utc_datetime
    field :badge_id, :id

    field :lock_version, :integer, default: 1

    timestamps()
  end

  def changeset(spotlight, attrs) do
    spotlight
    |> cast(attrs, [:end, :badge_id])
    |> validate_required([:end, :badge_id])
    |> validate_not_already_active()
    |> Ecto.Changeset.optimistic_lock(:lock_version)
  end

  defp validate_not_already_active(changeset) do
    if changeset.data do
      spotlight = Interaction.get_spotlight()

      if spotlight && DateTime.compare(spotlight.end, DateTime.utc_now()) == :gt do
        add_error(changeset, :end, "Another spotlight is still active")
      else
        changeset
      end
    end
  end
end

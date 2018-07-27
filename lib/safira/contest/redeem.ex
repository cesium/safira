defmodule Safira.Contest.Redeem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Manager


  schema "redeems" do
    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :manager, Manager
    belongs_to :badge, Badge

    timestamps()
  end

  @doc false
  def changeset(redeem, attrs) do
    redeem
    |> cast(attrs, [:attendee_id, :manager_id, :badge_id])
    |> validate_required([:attendee_id, :badge_id])
    |> unique_constraint(:unique_attendee_badge, name: :unique_attendee_badge)
  end
end

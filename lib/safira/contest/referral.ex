defmodule Safira.Contest.Referral do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge
  alias Safira.Accounts.Attendee

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "referrals" do
    field :available, :boolean, default: true
    belongs_to :badge, Badge
    belongs_to :attendee, Attendee

    timestamps()
  end

  def changeset(referral, attrs) do
    referral
    |> cast(attrs, [:badge_id, :available, :attendee_id])
    |> validate_required([:badge_id, :available, :attendee_id])
  end
end

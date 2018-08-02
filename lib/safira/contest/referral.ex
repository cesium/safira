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
    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id

    timestamps()
  end

  def changeset(referral, attrs) do
    referral
    |> cast(attrs, [:badge_id, :available, :attendee_id])
    |> validate_required([:badge_id, :available])
    |> validate_redeem
  end

  defp validate_redeem(changeset) do
    {_, available} = fetch_field(changeset, :available)
    {_, attendee_id} = fetch_field(changeset, :attendee_id)

    case {available, !attendee_id} do
      {false, true}->
        add_error(changeset, :attendee_id, "A referral redeem can't have an nil attendee")
      {true, false}->
        add_error(changeset, :attendee_id, "An available referral can't have an attendee")
      _ ->
        changeset
    end
  end
end

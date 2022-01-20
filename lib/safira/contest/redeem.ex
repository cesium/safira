defmodule Safira.Contest.Redeem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Manager
  alias Safira.Accounts

  schema "redeems" do
    belongs_to(:attendee, Attendee, foreign_key: :attendee_id, type: :binary_id)
    belongs_to(:manager, Manager)
    belongs_to(:badge, Badge)

    timestamps()
  end

  @doc false
  def changeset(redeem, attrs) do
    redeem
    |> cast(attrs, [:attendee_id, :manager_id, :badge_id])
    |> validate_required([:attendee_id, :badge_id])
    |> unique_constraint(:unique_attendee_badge,
      name: :unique_attendee_badge,
      message: "An attendee can't have the same badge twice"
    )
    |> check_period()
  end

  def check_period(changeset) do
    attendee_id = fetch_field(changeset, :attendee_id)
    case attendee_id do
      :error ->
        is_within_period(changeset)
      _ ->
        if Accounts.is_admin(attendee_id) do
          changeset
        else
          is_within_period(changeset)
    end
  end

  def is_within_period(changeset) do
    {_, badge} = fetch_field(changeset, :badge)
    curr = Datetime.utc_now()

    cond do
      Datetime.compare(curr, badge.start) == :lt ->
        add_error(changeset, :begin, "Badge cannot be redeemed before the activity")

      Datetime.compare(curr, badge.end) == :gt ->
        add_error(changeset, :end, "Badge cannot be redeemed after the activity")

      true ->
        changeset
    end
  end
end

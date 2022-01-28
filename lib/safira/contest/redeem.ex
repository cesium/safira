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
  def changeset(redeem, attrs, user_type \\ :manager) do
    redeem
    |> cast(attrs, [:attendee_id, :manager_id, :badge_id])
    |> validate_required([:attendee_id, :badge_id])
    |> unique_constraint(:unique_attendee_badge,
      name: :unique_attendee_badge,
      message: "An attendee can't have the same badge twice"
    )
    |> check_period(user_type)
  end

  defp check_period(changeset, user_type) do
    case user_type do
      :admin ->
          changeset
      _ ->
        is_within_period(changeset)
    end
  end

  defp is_within_period(changeset) do
    {_, badge} = fetch_field(changeset, :badge)
    curr = DateTime.utc_now()

    cond do
      DateTime.compare(curr, badge.begin) == :lt ->
        add_error(changeset, :begin, "Badge cannot be redeemed before the activity")

      DateTime.compare(curr, badge.end) == :gt ->
        add_error(changeset, :end, "Badge cannot be redeemed after the activity")

      true ->
        changeset
    end
  end
end

defmodule Safira.Contest.Redeem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge
  alias Safira.Contest
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
    |> foreign_key_contraint(:foreign_key_constraint, :name)
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
    {_, badge_id} = fetch_field(changeset, :badge_id)
    badge = Contest.get_badge!(badge_id)
    curr = DateTime.utc_now()

    cond do
      DateTime.compare(curr, badge.begin_badge) == :lt ->
        add_error(changeset, :begin_badge, "Can't redeem Badge before badge-gifting period")

      DateTime.compare(curr, badge.end_badge) == :gt ->
        add_error(changeset, :end_badge, "Can't redeem Badge before badge-gifting period")

      true ->
        changeset
    end
  end
end

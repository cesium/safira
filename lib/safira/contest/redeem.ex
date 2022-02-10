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
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:manager_id)
    |> validate_required([:attendee_id, :badge_id])
    |> unique_constraint(:unique_attendee_badge,
      name: :unique_attendee_badge,
      message: "An attendee can't have the same badge twice"
    )
    |> check_period(user_type)
    |> simultaneous_constraint(user_type)
  end

  # verificar se não tem já um badge de uma talk ou workshop nessa hora
  def simultaneous_constraint(changeset, user_type) do
    case user_type do 
      :admin ->
        changeset
      _ ->
        {_, attendee_id} = fetch_field(changeset, :attendee_id)
        {_, badge_id} = fetch_field(changeset, :badge_id)
        attendee = Accounts.get_attendee!(attendee_id)
        badges = attendee.badges
        badge = Contest.get_badge!(badge_id)

        if Enum.any?(badges, &coincidental(badge, &1, user_type)) do
          add_error(
            changeset,
            :badge,
            "Attendee already has badge for an activity within that period"
          )
        else
          changeset
        end
    end
  end

  # workshops, pitches, talks
  def is_unique_type(type) do
    type == 6 or type == 7 or type == 9
  end

  # verifica se os badges sao simultaneos e algum deles é um workshop
  def coincidental(badge_a, badge_b, user_type) do
    user_type != :admin and 
      DateTime.compare(badge_a.begin, badge_b.end) == :lt and
      DateTime.compare(badge_b.begin, badge_a.end) == :lt and
      is_unique_type(badge_a.type) and is_unique_type(badge_b.type)
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
        add_error(changeset, :end_badge, "Can't redeem Badge after badge-gifting period")

      true ->
        changeset
    end
  end
end

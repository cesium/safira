defmodule Safira.Contest.Badge do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Contest.Referral
  alias Safira.Contest.Redeem
  alias Safira.Accounts.Attendee

  schema "badges" do
    field(:name, :string)
    field(:description, :string)

    field(:begin_activity, :utc_datetime)
    field(:end_activity, :utc_datetime)
    field(:begin_badge, :utc_datetime)
    field(:end_badge, :utc_datetime)

    field(:avatar, Safira.Avatar.Type)

    # %{verificações: 0, secret: 1, desafios: 2, geral: 3, empresas: 4, oradores: 5, talks: 6, workshops: 7, discord: 8, pitches: 9}
    field(:type, :integer)
    field(:tokens, :integer)

    has_many(:referrals, Referral)
    many_to_many(:attendees, Attendee, join_through: Redeem)

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [
      :name,
      :description,
      :begin_activity,
      :end_activity,
      :begin_badge,
      :end_badge,
      :type,
      :tokens
    ])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([
      :name,
      :description,
      :begin_activity,
      :end_activity,
      :begin_badge,
      :end_badge,
      :type,
      :tokens
    ])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, min: 1, max: 1000)
    |> validate_time
  end

  @doc false
  def admin_changeset(badge, attrs) do
    badge
    |> cast(attrs, [
      :begin_activity,
      :end_activity,
      :begin_badge,
      :end_badge,
      :name,
      :description,
      :type,
      :tokens
    ])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([
      :begin_activity,
      :end_activity,
      :begin_badge,
      :end_badge,
      :name,
      :description,
      :type,
      :tokens
    ])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, min: 1, max: 1000)
    |> validate_time
  end

  defp validate_time(changeset) do
    {_, begin_activity} = fetch_field(changeset, :begin_activity)
    {_, end_activity} = fetch_field(changeset, :end_activity)
    {_, begin_badge} = fetch_field(changeset, :begin_badge)
    {_, end_badge} = fetch_field(changeset, :end_badge)

    cond do
      case DateTime.compare(begin_activity, end_activity)
        and Datetime.compare(begin_badge,end_badge) do
          :lt -> changeset
          _ -> add_error(changeset, :begin, "Begin time can't be after end time")
        end

      _ ->
        add_error(changeset, :begin, "Times not correct format")
    end
  end
end

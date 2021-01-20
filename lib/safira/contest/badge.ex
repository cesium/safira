defmodule Safira.Contest.Badge do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Contest.Referral
  alias Safira.Contest.Redeem
  alias Safira.Accounts.Attendee

  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :name, :string
    field :description, :string
    field :avatar, Safira.Avatar.Type
    #%{hidden: 0, secret: 1, empresa: 2, talk: 3, workshop: 4, oradore: 5, dias: 6, outros: 7}
    field :type, :integer
    field :tokens, :integer


    has_many :referrals, Referral
    many_to_many :attendees, Attendee, join_through: Redeem

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [:name, :description, :begin, :end, :type, :tokens])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:name, :description, :begin, :end, :type])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, min: 1, max: 1000)
    |> validate_time
  end

  @doc false
  def admin_changeset(badge, attrs) do
    badge
    |> cast(attrs, [:begin, :end, :name, :description, :type, :tokens])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:begin, :end, :name, :description, :type])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, min: 1, max: 1000)
    |> validate_time
  end

  defp validate_time(changeset) do
    {_, begin_time} = fetch_field(changeset, :begin)
    {_, end_time} = fetch_field(changeset, :end)

    case !!begin_time and !!end_time do
      true ->
        case DateTime.compare(begin_time, end_time) do
          :lt -> changeset
          _ -> add_error(changeset, :begin, "Begin time can't be after end time" )
        end
      _ -> add_error(changeset, :begin, "Times not correct format" )
    end
  end
end

defmodule Safira.Contest.Badge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Referral
  alias Safira.Contest.Redeem
  alias Safira.Accounts.Attendee

  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :name, :string
    field :description, :string

    has_many :referrals, Referral
    many_to_many :attendees, Attendee, join_through: Redeem

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [:name, :description,:begin, :end])
    |> validate_required([:name, :description, :begin, :end])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, min: 1, max: 450)
    |> validate_time
  end


  def validate_time(changeset) do
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

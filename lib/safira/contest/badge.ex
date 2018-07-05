defmodule Safira.Contest.Badge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Referral

  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :name, :string
    field :description, :string

    has_many :referrals, Referral

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

    case Time.compare(begin_time, end_time) do
      :lt -> changeset
      _ -> add_error(changeset, :begin, "Begin time can't be after end time" )
    end
  end
end

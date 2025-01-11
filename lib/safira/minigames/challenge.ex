defmodule Safira.Minigames.Challenge do
  @moduledoc """
  Challenges attendees participate in to gain prizes
  """

  use Safira.Schema

  alias Safira.Minigames.{ChallengePrize, Prize}

  @required_fields ~w(name description type)a
  @optional_fields ~w(date)a

  @challenge_types ~w(daily global other)a

  schema "challenges" do
    field :name, :string
    field :description, :string

    field :type, Ecto.Enum, values: @challenge_types
    field :date, :date

    many_to_many :prizes, Prize, join_through: ChallengePrize

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

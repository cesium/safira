defmodule Safira.Challenges.Challenge do
  @moduledoc """
  Challenges attendees participate in to gain prizes
  """

  use Safira.Schema

  alias Safira.Challenges.ChallengePrize

  @required_fields ~w(display_priority name description type)a
  @optional_fields ~w(date)a

  @challenge_types ~w(daily global other)a

  @derive {
    Flop.Schema,
    filterable: [:name], sortable: [:name, :date, :type], default_limit: 11
  }
  schema "challenges" do
    field :name, :string
    field :description, :string
    field :display_priority, :integer

    field :type, Ecto.Enum, values: @challenge_types
    field :date, :date

    has_many :prizes, ChallengePrize, preload_order: [asc: :place], on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:prizes,
      sort_param: :prizes_sort,
      drop_param: :prizes_drop,
      with: &ChallengePrize.embedded_changeset/2
    )
  end

  def challenge_types do
    @challenge_types
  end
end

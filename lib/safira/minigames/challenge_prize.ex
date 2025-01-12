defmodule Safira.Minigames.ChallengePrize do
  @moduledoc """
  Association between challenges and prizes
  """

  use Safira.Schema

  alias Safira.Minigames.{Challenge, Prize}

  @required_fields ~w(challenge_id prize_id place)a

  schema "challenges_prizes" do
    belongs_to :prize, Prize
    belongs_to :challenge, Challenge

    field :place, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(challenge_prize, attrs) do
    challenge_prize
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:place, greater_than: 0)
  end

  @doc false
  def embedded_changeset(challenge_prize, attrs) do
    challenge_prize
    |> cast(attrs, @required_fields)
    |> validate_required([:place, :prize_id])
    |> validate_number(:place, greater_than: 0)
  end
end

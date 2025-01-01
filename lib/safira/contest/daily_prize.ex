defmodule Safira.Contest.DailyPrize do
  @moduledoc """
  General prizes, that can be won by having more badges and tokens at the end
  of a day or of the whole event
  """

  use Safira.Schema

  @required_fields ~w(prize_id place)a
  @optional_fields ~w(date)a

  schema "daily_prizes" do
    belongs_to :prize, Safira.Minigames.Prize
    field :date, :date
    field :place, :integer

    timestamps()
  end

  @doc false
  def changeset(daily_prize, attrs) do
    daily_prize
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:date, :place])
  end
end

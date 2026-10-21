defmodule Safira.Minigames.ScratchCardDrop do
  @moduledoc """
    Scratch card drop schema
  """

  use Safira.Schema

  @required_fields ~w(probability max_per_attendee)a
  @optional_fields ~w(prize_id badge_id scratch_card_symbol_id tokens entries)a

  schema "scratch_card_drops" do
    field :probability, :float
    field :max_per_attendee, :integer
    field :tokens, :integer, default: 0
    field :entries, :integer, default: 0

    belongs_to :scratch_card_symbol, Safira.Minigames.ScratchCardSymbol
    belongs_to :prize, Safira.Minigames.Prize
    belongs_to :badge, Safira.Contest.Badge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card_drop, attrs) do
    scratch_card_drop
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:max_per_attendee, greater_than_or_equal_to: 0)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> validate_number(:entries, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:prize_id)
    |> foreign_key_constraint(:badge_id)
    |> foreign_key_constraint(:scratch_card_symbol_id)
  end
end

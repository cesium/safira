defmodule Safira.Minigames.ScratchCardSymbol do
  @moduledoc """
  Scratch card symbols.
  """
  use Safira.Schema

  import Ecto.Changeset

  @required_fields ~w(name)a
  @optional_fields ~w(image)a

  schema "scratch_card_symbols" do
    field :name, :string
    field :image, Uploaders.ScratchCardSymbols.Type

    has_one :scratch_card_drop, Safira.Minigames.ScratchCardDrop
    many_to_many :scratch_cards, Safira.Minigames.ScratchCard, join_through: "cards_symbols"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scratch_card_symbol, attrs) do
    scratch_card_symbol
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_attachments(attrs, [:image])
    |> validate_required(@required_fields)
  end

  def image_changeset(scratch_card_symbol, attrs) do
    scratch_card_symbol
    |> cast_attachments(attrs, [:image])
  end
end

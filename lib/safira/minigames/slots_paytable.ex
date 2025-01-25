defmodule Safira.Minigames.SlotsPaytable do
  @moduledoc """
  Slots paytable.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "slots_paytables" do
    field :multiplier, :integer
    field :position_figure_0, :integer
    field :position_figure_1, :integer
    field :position_figure_2, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slots_paytable, attrs) do
    slots_paytable
    |> cast(attrs, [:multiplier, :position_figure_0, :position_figure_1, :position_figure_2])
    |> validate_required([:multiplier, :position_figure_0, :position_figure_1, :position_figure_2])
  end
end

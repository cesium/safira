defmodule Safira.Minigames.SlotsReelIcon do
  @moduledoc """
  Slots reel icon.
  """
  use Safira.Schema

  import Ecto.Changeset

  @required_fields ~w(reel_0_index reel_1_index reel_2_index)a
  @optional_fields ~w(image)a

  schema "slots_reel_icons" do
    field :image, Uploaders.SlotsReelIcon.Type
    field :reel_0_index, :integer
    field :reel_1_index, :integer
    field :reel_2_index, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slots_reel_icon, attrs) do
    slots_reel_icon
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @doc false
  def image_changeset(slots_reel_icon, attrs) do
    slots_reel_icon
    |> cast_attachments(attrs, [:image])
  end
end

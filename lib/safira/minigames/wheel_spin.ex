defmodule Safira.Minigames.WheelSpin do
  @moduledoc """
  Lucky wheel minigame spin result
  """

  use Safira.Schema

  @required_fields ~w(attendee_id drop_id)a

  schema "wheel_spins" do
    belongs_to :attendee, Safira.Accounts.Attendee
    belongs_to :drop, Safira.Minigames.WheelDrop

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wheel_spin, attrs) do
    wheel_spin
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

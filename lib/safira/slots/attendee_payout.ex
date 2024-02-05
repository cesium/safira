defmodule Safira.Slots.AttendeePayout do
  @moduledoc """
  Intermediate schema to register slot payouts won by attendees or losses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee
  alias Safira.Slots.Payout

  schema "attendees_payouts" do
    field :bet, :integer
    field :tokens, :integer

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :payout, Payout

    timestamps()
  end

  @doc false
  def changeset(attendee_prize, attrs) do
    attendee_prize
    |> cast(attrs, [:bet, :tokens, :attendee_id, :payout_id])
    |> validate_required([:bet, :tokens, :attendee_id])
    |> unique_constraint(:unique_attendee_payout)
    |> validate_number(:bet, greater_than: 0)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:payout_id)
  end
end

defmodule Safira.Contest.Buy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Redeemable
  alias Safira.Accounts.Attendee

  schema "buys" do
    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :redeemable, Redeemable, foreign_key: :redeemable_id, type: :binary_id

    timestamps()
  end

  def changeset(buy, attrs) do
    buy
    |> cast(attrs, [:attendee_id, :redeemable_id])
    |> validate_required([:attendee_id, :redeemable_id])
  end

end
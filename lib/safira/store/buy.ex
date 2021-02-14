defmodule Safira.Store.Buy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Store.Redeemable
  alias Safira.Accounts.Attendee

  schema "buys" do
    field :quantity, :integer

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :redeemable, Redeemable, foreign_key: :redeemable_id

    timestamps()
  end

  def changeset(buy, attrs) do
    buy
    |> cast(attrs, [:attendee_id, :redeemable_id, :quantity])
    |> validate_required([:attendee_id, :redeemable_id, :quantity])
  end
end

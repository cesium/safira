defmodule Safira.Inventory.Item do
  @moduledoc """
  Item present in an attendee's inventory.
  """
  use Safira.Schema

  @derive {
    Flop.Schema,
    filterable: [:attendee_id, :product_id], sortable: [:redeemed_at], default_limit: 11
  }

  @required_fields ~w(type attendee_id)a
  @optional_fields ~w(redeemed_at product_id prize_id staff_id)a

  schema "items" do
    field :redeemed_at, :naive_datetime
    field :type, Ecto.Enum, values: [:product, :prize]

    belongs_to :attendee, Safira.Accounts.Attendee
    belongs_to :product, Safira.Store.Product
    belongs_to :prize, Safira.Minigames.Prize
    belongs_to :staff, Safira.Accounts.Staff

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:attendee)
    |> cast_assoc(:product)
    |> cast_assoc(:prize)
    |> cast_assoc(:staff)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:prize_id)
    |> foreign_key_constraint(:staff_id)
    |> validate_required(@required_fields)
  end
end

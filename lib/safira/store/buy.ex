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
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_quantity
  end

  defp validate_quantity(changeset) do
    {_, redeemable_id} = fetch_field(changeset, :redeemable_id)
    {_, quantity} = fetch_field(changeset, :quantity)
    case {redeemable_id, quantity} do
      {nil, nil } -> 
        add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")
        add_error(changeset, :quantity, "Quantity shouldn't be nil")
      {nil, _ } -> add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")
      {_, nil } -> add_error(changeset, :quantity, "Quantity shouldn't be nil")
      
      {_, _ } -> 
        redeemable = Redeemable
                     |> Repo.get(redeemable_id)
        cond do
          redeemable.max_per_user >= quantity ->
            changeset
          true ->
            add_error( changeset, :quantity,
              "Quantity is greater than the maximum amount permitted per attendee")
        end
    end
  end
end

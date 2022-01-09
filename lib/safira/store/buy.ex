defmodule Safira.Store.Buy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Store.Redeemable
  alias Safira.Accounts.Attendee
  alias Safira.Repo

  schema "buys" do
    field :quantity, :integer
    field :redeemed, :integer, default: 0 #default 0 should mean all previous code still works as intended when creating a "buy"

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :redeemable, Redeemable, foreign_key: :redeemable_id

    timestamps()
  end

  def changeset(buy, attrs) do
    buy
    |> cast(attrs, [:attendee_id, :redeemable_id, :quantity, :redeemed])
    |> unique_constraint(:unique_attendee_redeemable)
    |> validate_required([:attendee_id, :redeemable_id, :quantity])
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:redeemed, greater_than_or_equal_to: 0)
    |> validate_quantity
    |> validate_redeemed
  end

  defp validate_quantity(changeset) do
    {_, redeemable_id} = fetch_field(changeset, :redeemable_id)
    {_, quantity} = fetch_field(changeset, :quantity)

    case {redeemable_id, quantity} do
      {nil, nil} ->
        add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")
        add_error(changeset, :quantity, "Quantity shouldn't be nil")

      {nil, _} ->
        add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")

      {_, nil} ->
        add_error(changeset, :quantity, "Quantity shouldn't be nil")

      {_, _} ->
        redeemable =
          Redeemable
          |> Repo.get!(redeemable_id)

        cond do
          redeemable.max_per_user >= quantity ->
            changeset

          true ->
            add_error(
              changeset,
              :quantity,
              "Quantity is greater than the maximum amount permitted per attendee"
            )
        end
    end
  end

#ensures that the max amount of redeemd items is less than the total amount bought
  defp validate_redeemed(changeset) do
    {_, redeemable_id} = fetch_field(changeset, :redeemable_id)
    {_, redeemed} = fetch_field(changeset, :redeemed)
    {_, quantity} = fetch_field(changeset, :quantity)

    case {redeemable_id, redeemed} do
      {nil, nil} ->
        add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")
        add_error(changeset, :redeemed, "Redeemed shouldn't be nil")

      {nil, _} ->
        add_error(changeset, :redeemable_id, "Redeemable shouldn't be nil")

      {_, nil} ->
        add_error(changeset, :redeemed, "Redeemed shouldn't be nil")

      {_, _} ->
        cond do
          quantity >= redeemed ->
            changeset

          true ->
            add_error(
              changeset,
              :quantity,
              "Redeemed is greater than the quantity bought by the atendee"
            )
        end
    end
  end

end

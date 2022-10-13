defmodule Safira.Roulette.AttendeePrize do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.Attendee
  alias Safira.Roulette.Prize
  alias Safira.Repo

  schema "attendees_prizes" do
    field :quantity, :integer
    # default 0 should mean all previous code
    field :redeemed, :integer, default: 0

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :prize, Prize

    timestamps()
  end

  @doc false
  def changeset(attendee_prize, attrs) do
    attendee_prize
    |> cast(attrs, [:quantity, :attendee_id, :prize_id, :redeemed])
    |> unique_constraint(:unique_attendee_prize)
    |> validate_required([:quantity, :attendee_id, :prize_id])
    |> unique_constraint(:unique_attendee_prize)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:redeemed, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:prize_id)
    |> validate_quantity
    |> validate_redeemed
  end

  defp validate_quantity(changeset) do
    {_, prize_id} = fetch_field(changeset, :prize_id)
    {_, quantity} = fetch_field(changeset, :quantity)

    case {prize_id, quantity} do
      {nil, nil} ->
        add_error(changeset, :prize_id, "Prize shouldn't be nil")
        add_error(changeset, :quantity, "Quantity shouldn't be nil")

      {nil, _} ->
        add_error(changeset, :prize_id, "Prize shouldn't be nil")

      {_, nil} ->
        add_error(changeset, :quantity, "Quantity shouldn't be nil")

      {_, _} ->
        prize =
          Prize
          |> Repo.get(prize_id)

        cond do
          prize.max_amount_per_attendee >= quantity ->
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

  # ensures that the max amount of redeemed items is less than the total amount bought
  defp validate_redeemed(changeset) do
    {_, prize_id} = fetch_field(changeset, :prize_id)
    {_, redeemed} = fetch_field(changeset, :redeemed)
    {_, quantity} = fetch_field(changeset, :quantity)

    case {prize_id, redeemed} do
      {nil, nil} ->
        add_error(changeset, :prize_id, "Prize shouldn't be nil")
        add_error(changeset, :redeemed, "Redeemed shouldn't be nil")

      {nil, _} ->
        add_error(changeset, :prize_id, "Prize shouldn't be nil")

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

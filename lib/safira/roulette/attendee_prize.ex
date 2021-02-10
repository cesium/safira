defmodule Safira.Roulette.AttendeePrize do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.Attendee
  alias Safira.Roulette.Prize

  schema "attendees_prizes" do
    field :quantity, :integer

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :prize, Prize

    timestamps()
  end

  @doc false
  def changeset(attendee_prize, attrs) do
    attendee_prize
    |> cast(attrs, [:quantity, :attendee_id, :prize_id])
    |> validate_required([:quantity, :attendee_id, :prize_id])
    |> unique_constraint(:unique_attendee_prize)
    |> validate_number(:quantity, greater_than: 0)
  end
end

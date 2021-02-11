defmodule Safira.Roulette.Prize do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee

  schema "prizes" do
    field :name, :string
    field :stock, :integer
    field :max_amount_per_attendee, :integer
    field :probability, :float
    field :avatar, Safira.Avatar.Type

    many_to_many :attendees, Attendee, join_through: AttendeePrize

    timestamps()
  end

  @doc false
  def changeset(prize, attrs) do
    prize
    |> cast(attrs, [:name, :stock, :max_amount_per_attendee, :probability])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:name, :stock, :max_amount_per_attendee, :probability])
    |> validate_number(:max_amount_per_attendee, greater_than: 0)
    |> (&validate_number(&1, :stock,
          greater_than_or_equal_to: fetch_field(&1, :max_amount_per_attendee) |> elem(1)
        )).()
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
  end

  def update_changeset(prize, attrs) do
    prize
    |> cast(attrs, [:name, :stock, :max_amount_per_attendee, :probability])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:name, :stock, :max_amount_per_attendee, :probability])
    |> validate_number(:max_amount_per_attendee, greater_than: 0)
    |> validate_number(:stock, greater_than: 0)
    |> validate_number(:probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
  end
end

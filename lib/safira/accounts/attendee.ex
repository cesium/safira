defmodule Safira.Accounts.Attendee do
  use Safira.Schema

  @required_fields ~w(user_id)a
  @optional_fields ~w(tokens entries)a

  schema "attendees" do
    field :tokens, :integer, default: 0
    field :entries, :integer, default: 0

    belongs_to :user, Safira.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end

  def update_tokens_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, ~w(tokens)a)
    |> validate_required(~w(tokens)a)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
  end
end

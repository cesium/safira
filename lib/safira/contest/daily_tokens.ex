defmodule Safira.Contest.DailyTokens do
  use Safira.Schema

  @required_fields ~w(date tokens attendee_id)a

  schema "daily_tokens" do
    field :date, :date
    field :tokens, :integer

    belongs_to :attendee, Safira.Accounts.Attendee

    timestamps()
  end

  @doc false
  def changeset(daily_tokens, attrs) do
    daily_tokens
    |> cast(attrs, @required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> validate_number(:tokens, greater_than: 0)
    |> validate_required(@required_fields)
    |> unique_constraint([:date, :attendee_id])
  end
end

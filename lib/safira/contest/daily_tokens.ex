defmodule Safira.Contest.DailyTokens do
  @moduledoc """
  Daily tokens schema.
  """
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
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:attendee_id)
    |> validate_number(:tokens, greater_than_or_equal_to: 0)
    |> unique_constraint([:date, :attendee_id])
  end
end

defmodule Safira.Contest.DailyToken do
  @moduledoc """
  Attendees gain tokens for every day they participate in SEI
  """
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee

  schema "daily_tokens" do
    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id

    field :day, :utc_datetime
    field :quantity, :integer

    timestamps()
  end

  def changeset(redeemable, attrs) do
    redeemable
    |> cast(attrs, [:attendee_id, :day, :quantity])
    |> validate_required([:attendee_id, :day, :quantity])
  end
end

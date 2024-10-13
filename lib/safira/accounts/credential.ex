defmodule Safira.Accounts.Credential do
  @moduledoc """
  Attendee's physical credentials.
  """
  use Safira.Schema

  schema "credentials" do
    belongs_to :attendee, Safira.Accounts.Attendee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:attendee_id])
    |> cast_assoc(:attendee)
  end
end

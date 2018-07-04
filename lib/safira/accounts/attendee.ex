defmodule Safira.Accounts.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User


  schema "attendees" do
    field :nickname, :string
    field :uuid, :string

    belongs_to :user, User

    timestamps()
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:uuid, :nickname, :user_id])
    |> cast_assoc(:user)
    |> validate_required([:uuid, :nickname])
    |> unique_constraint(:uuid)
    |> unique_constraint(:nickname)
  end
end

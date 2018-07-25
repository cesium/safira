defmodule Safira.Accounts.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "attendees" do
    field :nickname, :string
    field :volunteer, :boolean, default: false

    belongs_to :user, User

    timestamps()
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:nickname, :volunteer, :user_id])
    |> cast_assoc(:user)
    |> validate_required([:nickname, :volunteer])
    |> unique_constraint(:nickname)
  end
end

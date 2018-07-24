defmodule Safira.Accounts.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User

  schema "staffs" do
    field :active, :boolean

    belongs_to :user, User

    timestamps()
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:active])
    |> cast_assoc(:user)
    |> validate_required([:active])
  end
end

defmodule Safira.Accounts.Manager do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User

  schema "managers" do
    field :active, :boolean

    belongs_to :user, User

    timestamps()
  end

  def changeset(manager, attrs) do
    manager
    |> cast(attrs, [:active])
    |> cast_assoc(:user)
    |> validate_required([:active])
  end
end

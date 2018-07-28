defmodule Safira.Accounts.Manager do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User
  alias Safira.Contest.Redeem

  schema "managers" do
    field :active, :boolean, default: true

    belongs_to :user, User
    has_many :redeems, Redeem

    timestamps()
  end

  def changeset(manager, attrs) do
    manager
    |> cast(attrs, [:active])
    |> cast_assoc(:user)
    |> validate_required([:active])
  end
end

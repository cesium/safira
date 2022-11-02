defmodule Safira.Accounts.Manager do
  @moduledoc """
  A manager is a staff member who can give attendees badges and
  deliver them prizes they win throughout the event
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User
  alias Safira.Contest.Redeem

  schema "managers" do
    field :active, :boolean, default: true
    field :is_admin, :boolean, default: false

    belongs_to :user, User
    has_many :redeems, Redeem

    timestamps()
  end

  def changeset(manager, attrs) do
    manager
    |> cast(attrs, [:active, :is_admin])
    |> cast_assoc(:user)
    |> validate_required([:active, :is_admin])
  end
end

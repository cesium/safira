defmodule Safira.Accounts.Role do
  @moduledoc """
  Role for an event staff.
  """
  use Safira.Schema

  alias Safira.Accounts.Roles.Permissions

  schema "roles" do
    field :name, :string
    field :permissions, :map

    has_many :users, Safira.Accounts.Staff

    timestamps(type: :utc_datetime)
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name, :permissions])
    |> unique_constraint(:name)
    |> validate_at_least_one_permission()
    |> Permissions.validate_permissions(:permissions)
  end

  defp validate_at_least_one_permission(changeset) do
    validate_change(changeset, :permissions, fn field, permissions ->
      if map_size(permissions) == 0 do
        [{field, "must have at least one permission"}]
      else
        []
      end
    end)
  end
end

defmodule Safira.Accounts.Staff do
  use Safira.Schema

  @required_fields ~w(user_id)a
  @optional_fields ~w()a

  schema "staffs" do
    belongs_to :user, Safira.Accounts.User
    belongs_to :role, Safira.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:user)
    |> validate_required(@required_fields)
  end
end

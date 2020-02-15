defmodule Safira.Admin.Accounts.AdminUser do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "admin_users" do
    pow_user_fields()

    timestamps()
  end
end

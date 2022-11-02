defmodule Safira.Admin.Accounts.AdminUser do
  @moduledoc false
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "admin_users" do
    pow_user_fields()

    timestamps()
  end
end

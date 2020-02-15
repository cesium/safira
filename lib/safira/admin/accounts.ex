defmodule Safira.Admin.Accounts do
  @moduledoc """
  The Admin.Accounts context.
  """

  import Ecto.Query, warn: false
  alias Safira.Repo
  alias Safira.Admin.Accounts.AdminUser
  
  def list_admin_users do
    Repo.all(AdminUser)
  end
end

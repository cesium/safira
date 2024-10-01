defmodule SafiraWeb.BackofficeHelpers do
  @moduledoc """
  Helper functions for backoffice live views.
  """

  @doc """
  Check if the user has the required permissions.

  ## Examples

      iex> has_scopes?(%{
              "attendees" => ["show", "edit"],
              "badges" => ["show", "edit", "delete", "give", "revoke",
              "give_without_restrictions"],
              "mailer" => ["send"],
              "minigames" => ["show", "edit", "simulate"],
              "products" => ["show", "edit", "delete"],
              "purchases" => ["show", "redeem", "refund"],
              "spotlights" => ["edit"],
              "staffs" => ["show", "edit", "roles_edit"],
              "statistics" => ["show"]
            }, {"staffs" => ["show", "edit"]})
      true

      iex> has_scopes?(%{"attendees" => ["show", "edit"]}, {"staffs" => ["show", "edit"]})
      false

      iex> has_scopes?(%{"attendees" => ["show", "edit"]}, {"attendees" => ["show", "edit"]})
      true
  """
  def has_scopes?(user_permissions, scopes) do
    scope_key = Map.keys(scopes) |> List.first()
    scope_value = Map.get(scopes, scope_key)

    values = Map.get(user_permissions, scope_key)

    Enum.all?(scope_value, fn x -> Enum.member?(values, x) end)
  end
end

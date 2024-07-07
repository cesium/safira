defmodule Safira.Accounts.Roles.Permissions do
  import Ecto.Changeset

  def all do
    %{
      "badges" => ["edit", "give"],
      "store" => ["edit_stock", "refund"],
      "users" => ["view", "edit"],
      "mailer" => ["edit_mailing_lists", "send"],
      "admin" => ["view_event_stats", "view_app_stats", "access_console"]
    }
  end

  def validate_permissions(changeset, field) do
    validate_change(changeset, field, fn _field, permissions ->
      permissions
      |> Enum.reject(&has_permission?(all(), &1))
      |> case do
        [] -> []
        invalid_permissions -> [{field, {"invalid permissions", invalid_permissions}}]
      end
    end)
  end

  def has_permission?(permissions, {name, actions}) do
    exists?(name, permissions) && actions_valid?(name, actions, permissions)
  end

  defp exists?(name, permissions), do: Map.has_key?(permissions, name)

  defp actions_valid?(permission_name, given_action, permissions) when is_binary(given_action) do
    actions_valid?(permission_name, [given_action], permissions)
  end

  defp actions_valid?(permission_name, given_actions, permissions) when is_list(given_actions) do
    defined_actions = Map.get(permissions, permission_name)
    Enum.all?(given_actions, &(&1 in defined_actions))
  end
end

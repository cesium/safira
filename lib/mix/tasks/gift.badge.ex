defmodule Mix.Tasks.Gift.Badge do
  use Mix.Task

  alias Safira.Contest
  alias Safira.Contest.Badge
  alias Safira.Accounts

  def run(args) do
    cond do
      length(args) != 2 ->
        Mix.shell.info "Needs to receive one file path or an attendee_id and a badge_id."
      args |> List.last |> String.to_integer < 0 ->
        Mix.shell.info "Number of badge_id needs to be above 0."
      true ->
        args |> create
    end
  end

  defp create(args) do
    Mix.Task.run "app.start"

    cond do
      is_valid_uuid(Enum.at(args, 0)) ->
        give_by_uuid(args)
      is_valid_email(Enum.at(args, 0)) ->
        give_by_email(args)
      File.regular?(Enum.at(args, 0)) ->
        give_by_file(args)
    end
  end

  defp is_valid_email(email) do
    case valid_email(email |> String.trim) do
      false -> false
      true -> is_register_email(email |> String.trim)
    end
  end

  defp is_register_email(email) do
    user = Accounts.get_user_preload_email!(email)
    not is_nil user.attendee
  end

  defp valid_email(email) do
    email
    |> String.trim
    |> String.match?(~r/\A[^@\s]+@[^@\s]+\z/)
  end

  defp give_by_email(args) do
    badge_id = List.last(args) |> String.to_integer
    if exists_badge(badge_id) do
      give_email(Enum.at(args, 0), badge_id)
    else
      Mix.shell.info "Badge_id needs to be valid."
    end
  end

  defp give_by_file(args) do
    badge_id = List.last(args) |> String.to_integer
    if exists_badge(badge_id) do
      Enum.at(args, 0)
      |> File.stream!
      |> Enum.map(fn x -> give_check(x |> String.trim, badge_id) end)
    else
      Mix.shell.info "Badge_id needs to be valid."
    end
  end

  defp is_valid_uuid(arg) do
    case Ecto.UUID.cast(arg) do
      {:ok, _} -> is_register(arg)
      :error -> false
    end
  end

  defp is_valid_uuid?(arg) do
    case Ecto.UUID.cast(arg) do
      {:ok, _} -> true
      :error -> false
    end
  end


  defp is_register(id) do
    attendee = Accounts.get_attendee!(id)
    not is_nil attendee.user_id
  end

  defp give_by_uuid(args) do
    badge_id = List.last(args) |> String.to_integer
    if exists_badge(badge_id) do
      give(Enum.at(args, 0), badge_id)
    else
      Mix.shell.info "Badge_id needs to be valid."
    end
  end

  defp exists_badge(id) do
    case Safira.Repo.get(Badge, id) do
      %Badge{} = _badge -> true
      nil -> false
    end
  end

  defp give(attendee_id, badge_id) do
    Contest.create_redeem(
      %{attendee_id: attendee_id,
        manager_id: 1,
        badge_id: badge_id
      }
    )
  end

  defp give_email(email, badge_id) do
    user = Accounts.get_user_preload_email(email)
    if not is_nil user do
      give(user.attendee.id, badge_id)
    else
      Mix.shell.info "Invalid email: #{email}"
    end
  end

  defp give_check(input, badge_id) do
    cond do
      is_valid_uuid?(input) ->
        give(input, badge_id)
      valid_email(input) ->
        give_email(input, badge_id)
    end
  end

end

defmodule Safira.Store do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Safira.Repo
  alias Safira.Store.Redeemable
  alias Safira.Store.Buy
  alias Safira.Accounts.Attendee

  def list_redeemables do
    Repo.all(Redeemable)
  end

  def get_redeemable!(id), do: Repo.get!(Redeemable, id)

  def get_redeemable(id) do
    Repo.get!(Redeemable, id)
  end

  def create_redeemable(attrs \\ %{}) do
    %Redeemable{}
    |> Redeemable.changeset(attrs)
    |> Repo.insert()
  end

  def get_keys_buy(attendee_id,redeemable_id) do
    Repo.get_by(Buy, [attendee_id: attendee_id, redeemable_id: redeemable_id])
  end

  def buy_redeemable(redeemable_id, attendee) do
    Multi.new()
    |> Multi.update(:redeemable,
            Redeemable.changeset(get_redeemable!(redeemable_id), %{stock: get_redeemable!(redeemable_id).stock - 1}))
    |> Multi.update(:attendee, fn %{redeemable: redeemable} ->
      Attendee.update_token_balance_changeset(attendee, %{
        token_balance: attendee.token_balance - redeemable.price}) end)
    |> Multi.run(:buy, fn _repo, %{attendee: attendee, redeemable: redeemable} ->
      {:ok, get_keys_buy(attendee.id, redeemable_id) ||
         %Buy{attendee_id: attendee.id, redeemable_id: redeemable.id, quantity: 0}} end)
    |> Multi.insert_or_update(:upsert_buy, fn %{buy: buy} ->
        Buy.changeset(buy, %{quantity: buy.quantity + 1}) end)
    |> serializable_transaction()
  end

  def get_attendee_redeemables(attendee) do
    redeemables = attendee
                  |> Repo.preload(:redeemables)
                  |> Map.fetch!(:redeemables)
                  |> Enum.map(fn redeemable ->
                    b = get_keys_buy(attendee.id,redeemable.id)
                    Map.put(redeemable, :quantity, b.quantity) end)
  end

  defp serializable_transaction(multi) do
    try do
      Repo.transaction(fn ->
        Repo.query!("set transaction isolation level serializable;")
        
        Repo.transaction(multi)
        |> case do
          {:ok, result} ->
            result

          {:error, _failed_operation, changeset, _changes_so_far} ->
            Repo.rollback(changeset)
          end
      end)
    rescue
      _error ->
        serializable_transaction(multi)
    end
  end
end

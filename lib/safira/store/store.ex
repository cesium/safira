defmodule Safira.Store do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Safira.Repo
  alias Safira.Store.Redeemable
  alias Safira.Store.Buy
  alias Safira.Accounts.Attendee
  alias Safira.Contest.DailyToken

  def list_redeemables do
    Repo.all(Redeemable)
  end

  def get_redeemable!(id), do: Repo.get!(Redeemable, id)

  def exist_redeemable(redeemable_id) do
    case redeemable_id do
      nil ->
        false
      _ ->
        query = from r in Redeemable,
            where: r.id == ^redeemable_id
        Repo.exists?(query)
    end
  end

  def list_store_redeemables(attendee) do
    Repo.all(Redeemable)
    |> Enum.map(fn redeemable -> add_can_buy(redeemable, attendee.id) end)
  end

  def get_redeemable_attendee(redeemable_id,attendee) do
    redeemable = get_redeemable!(redeemable_id)
    add_can_buy(redeemable, attendee.id)
  end

  defp add_can_buy(redeemable,attendee_id) do
    case get_keys_buy(attendee_id, redeemable.id) do
      nil ->
        Map.put(redeemable,:can_buy,Kernel.min(redeemable.max_per_user, redeemable.stock))
      buy ->
        Map.put(redeemable,:can_buy, Kernel.min(redeemable.max_per_user - buy.quantity, redeemable.stock))
    end
  end

  def create_redeemable(attrs \\ %{}) do
    %Redeemable{}
    |> Redeemable.changeset(attrs)
    |> Repo.insert()
  end

  def create_redeemables(list_redeemables) do
    list_redeemables
    |> Enum.with_index()
    |> Enum.reduce(Multi.new,fn {x,index}, acc ->
      Multi.insert(acc, index, Redeemable.changeset(%Redeemable{},x))
    end)
  end

  def update_redeemable(%Redeemable{} = redeemable, attrs) do
    redeemable
    |> Redeemable.changeset(attrs)
    |> Repo.update()
  end

  def get_keys_buy(attendee_id, redeemable_id) do
    Repo.get_by(Buy, attendee_id: attendee_id, redeemable_id: redeemable_id)
  end

  def buy_redeemable(redeemable_id, attendee) do
    Multi.new()
    # check if the redeemable in question exists
    |> Multi.run(:redeemable_info, fn _repo, _var -> {:ok, get_redeemable!(redeemable_id)} end)
    |> Multi.update(:redeemable, fn %{redeemable_info: redeemable} ->
      Redeemable.changeset(redeemable, %{stock: redeemable.stock - 1}) #removes 1 from the redeemable's stock
    end)
    |> Multi.update(:attendee, fn %{redeemable: redeemable} ->
      Attendee.update_token_balance_changeset(attendee, %{
        token_balance: attendee.token_balance - redeemable.price
      })
    end) #Removes the redeemable's price from the atendee's total balance
    |> Multi.run(:buy, fn _repo, %{attendee: attendee, redeemable: redeemable} ->
      {:ok,
       get_keys_buy(attendee.id, redeemable_id) ||
         %Buy{attendee_id: attendee.id, redeemable_id: redeemable.id, quantity: 0}}
    end) # fetches the buy repo if it exists or creates a new one if it doest exist
    |> Multi.insert_or_update(:upsert_buy, fn %{buy: buy} ->
      Buy.changeset(buy, %{quantity: buy.quantity + 1})
    end)
    |> Multi.insert_or_update(:daily_token, fn %{attendee: attendee} ->
      {:ok, date, _} = DateTime.from_iso8601("#{Date.utc_today()}T00:00:00Z")
      DailyToken.changeset(%DailyToken{}, %{quantity: attendee.token_balance, attendee_id: attendee.id, day: date})
    end) #increments the amount bought by 1
    |> serializable_transaction()
  end

  #redeems an item for an atendee, should only be used by managers
  def redeem_redeemable(redeemable_id, attendee, quantity) do
    Multi.new()
    |> Multi.run(:buy, fn _repo, _changes ->
      {:ok, get_keys_buy(attendee.id, redeemable_id)}
    end)
    |> Multi.run(:redeemable, fn _repo, _var -> {:ok, get_redeemable!(redeemable_id)} end)
    |> Multi.update(:update_buy, fn %{buy: buy} ->
      Buy.changeset(buy, %{redeemed: buy.redeemed + quantity})
    end)
    |> serializable_transaction()
  end

  def get_attendee_redeemables(attendee) do
    attendee
    |> Repo.preload(:redeemables)
    |> Map.fetch!(:redeemables)
    |> Enum.map(fn redeemable ->
      b = get_keys_buy(attendee.id, redeemable.id)
      Map.put(redeemable, :quantity, b.quantity)
    end)
  end

  ## fetches every redeemabla that has yet to be redeemed
  def get_attendee_not_redemed(attendee) do
    attendee
    |> Repo.preload(:redemables)
    |> Map.fetch!(:redeemables)
    |> Enum.filter( fn redeemable ->
      b = get_keys_buy(attendee.id, redeemable.id)
      b.quantity > 0 && b.quantity > b.redeemed
    end)
    |> Enum.map(fn redeemable ->
      b = get_keys_buy(attendee.id, redeemable.id)
        Map.put(redeemable, %{:quantity, b.quantity, :notredeemed , b.quantity - b.redeemed})
    end)
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

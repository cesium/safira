defmodule Safira.Contest do

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Safira.Repo
  alias Safira.Contest.Redeem
  alias Safira.Contest.Badge
  alias Ecto.Multi

  def list_badges do
    Repo.all(Badge)
  end

  def list_secret do
    Repo.all(from r in Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where: b.type == ^1 and not(a.volunteer) and not(is_nil(a.nickname)),
      preload: [badge: b, attendee: a],
      distinct: :badge_id)
    |> Enum.map(fn x -> x.badge end)

  end

  def list_normals do
    Repo.all(from b in  Badge,
      where: b.type != ^1 and b.type != ^0)
  end

  def list_badges_conservative do
    list_secret() ++ list_normals()
  end

  def get_badge!(id), do: Repo.get!(Badge, id)

  def get_badge_name!(name) do
    Repo.get_by!(Badge, name: name)
  end

  def get_badge_preload!(id) do
    Repo.get!(Badge, id)
    |> Repo.preload(:attendees)
  end

  def get_badge_description(description) do
    Repo.get_by!(Badge, description: description)
  end

  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  def create_badges(list_badges) do
    list_badges
    |> Enum.with_index()
    |> Enum.reduce(Multi.new,fn {x,index}, acc ->
      Ecto.Multi.insert(acc, index, Badge.changeset(%Badge{},x))
    end)
  end

  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  def delete_badge(%Badge{} = badge) do
    Repo.delete(badge)
  end

  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end

  alias Safira.Contest.Referral

  def list_referrals do
    Repo.all(Referral)
  end

  def get_referral!(id), do: Repo.get!(Referral, id)

  def get_referral_preload!(id) do
    Repo.get!(Referral, id)
    |> Repo.preload(:badge)
  end

  def create_referral(attrs \\ %{}) do
    %Referral{}
    |> Referral.changeset(attrs)
    |> Repo.insert()
  end

  def update_referral(%Referral{} = referral, attrs) do
    referral
    |> Referral.changeset(attrs)
    |> Repo.update()
  end

  def delete_referral(%Referral{} = referral) do
    Repo.delete(referral)
  end

  def change_referral(%Referral{} = referral) do
    Referral.changeset(referral, %{})
  end

  def list_redeems do
    Repo.all(Redeem)
  end

  def list_redeems_stats do
    Repo.all(from r in Redeem,
      join: b in assoc(r, :badge),
      join: a in assoc(r, :attendee),
      where: b.type == ^1 and not(a.volunteer) and not(is_nil(a.nickname)),
      preload: [badge: b, attendee: a])
  end

  def get_redeem!(id), do: Repo.get!(Redeem, id)

  def get_keys_redeem(attendee_id, badge_id) do
    Repo.get_by(Redeem, [attendee_id: attendee_id, badge_id: badge_id])
  end

  def create_redeem(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:redeem, Redeem.changeset(%Redeem{}, attrs))
    |> Multi.update(:attendee, fn %{redeem: redeem} ->
      redeem = Repo.preload(redeem, [:badge, :attendee])

      Changeset.change(redeem.attendee,
        token_balance: redeem.attendee.token_balance + redeem.badge.tokens
      )
    end)
    |> Repo.transaction()
    |> (fn x -> {elem(x, 0), elem(x, 1) |> Map.get(:redeem)} end).()
  end

  def update_redeem(%Redeem{} = redeem, attrs) do
    redeem
    |> Redeem.changeset(attrs)
    |> Repo.update()
  end

  def delete_redeem(%Redeem{} = redeem) do
    Repo.delete(redeem)
  end

  def change_redeem(%Redeem{} = redeem) do
    Redeem.changeset(redeem, %{})
  end

  def list_leaderboard do
    Repo.all(from a in Safira.Accounts.Attendee,
      where: not (is_nil a.user_id))
    #|> Repo.preload(:badges)
    |> Repo.preload([badges: from(b in Badge, where: b.type != ^0)])
    |> Enum.map(fn x -> Map.put(x, :badge_count, length(Enum.filter(x.badges,fn x -> x.type != 0 end))) end)
    |> Enum.sort(&(&1.badge_count >= &2.badge_count))
  end

  def list_daily_leaderboard(date) do
    Repo.all(
      from a in Safira.Accounts.Attendee,
        join: r in Redeem, on: a.id == r.attendee_id,
        join: b in Badge, on: r.badge_id == b.id,
        where: not(is_nil a.user_id) and fragment("?::date", r.inserted_at) == ^date and b.type != ^0,
        preload: [badges: b]
    )
    |> Enum.map(fn a -> Map.put(a, :badge_count, length(a.badges)) end)
    |> Enum.sort(&(&1.badge_count >= &2.badge_count))
  end

  def top_list_leaderboard(n) do
    list_leaderboard()
    |> Enum.take(n)
    |> Enum.map(fn a -> %{a.name => a.badge_count} end)
  end

  def get_winner do
    Repo.all(from a in Safira.Accounts.Attendee,
      where: not (is_nil a.user_id) and not(a.volunteer))
    |> Repo.preload([badges: from(b in Badge, where: b.type != ^0)])
    |> Enum.map(fn x -> Map.put(x, :badge_count, length(Enum.filter(x.badges,fn x -> x.type != 0 end))) end)
    |> Enum.filter(fn a -> a.badge_count >= 10 end)
    |> Enum.map(fn a -> Enum.map( Enum.filter(a.badges,fn b -> b.type != 0 end), fn x -> "#{a.nickname}:#{x.name}" end) end)
    |> List.flatten
  end
end

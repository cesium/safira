defmodule Safira.Contest do

  import Ecto.Query, warn: false
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
      where: b.type == 1, 
      preload: [badge: b], 
      distinct: :badge_id)
    |> Enum.map(fn x -> x.badge end) 
  end
  
  def list_normals do
     Repo.all(from b in  Badge, 
      where: (b.type != ^1)
      and (b.type != ^0))
  end

  def list_badges_conservative do
    Enum.concat(list_secret(),list_badges())
  end


  def get_badge!(id), do: Repo.get!(Badge, id)

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

  def get_redeem!(id), do: Repo.get!(Redeem, id)

  def create_redeem(attrs \\ %{}) do
    %Redeem{}
    |> Redeem.changeset(attrs)
    |> Repo.insert()
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
      where: not (is_nil a.user_id) and not a.volunteer)
    |> Repo.preload(:badges)
    |> Enum.map(fn x -> Map.put(x, :badge_count, length(Enum.filter(x.badges,fn x -> x.type != 0 end))) end)
    |> Enum.sort(&(&1.badge_count >= &2.badge_count))
  end
end

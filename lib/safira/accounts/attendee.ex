defmodule Safira.Accounts.Attendee do
  @moduledoc """
  An attendee is someone who is participating in SEI
  """
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User

  alias Safira.Contest.Badge
  alias Safira.Contest.DailyToken
  alias Safira.Contest.Redeem
  alias Safira.Contest.Referral

  alias Safira.Store.Buy
  alias Safira.Store.Redeemable

  alias Safira.Roulette.AttendeePrize
  alias Safira.Roulette.Prize

  @primary_key {:id, :binary_id, autogenerate: true}

  # Any sequence of 3-15 characters that are either letters, numbers, - or _
  @nickname_regex ~r/^[\w\d-_]{3,15}$/

  @derive {Phoenix.Param, key: :id}
  schema "attendees" do
    field :nickname, :string
    field :avatar, Safira.Avatar.Type
    field :name, :string
    field :token_balance, :integer, default: 0
    field :entries, :integer, default: 0
    field :discord_association_code, Ecto.UUID, autogenerate: true
    field :discord_id, :string
    field :cv, Safira.CV.Type

    belongs_to :user, User
    many_to_many :badges, Badge, join_through: Redeem
    has_many :referrals, Referral
    has_many :daily_tokens, DailyToken
    many_to_many :redeemables, Redeemable, join_through: Buy
    many_to_many :prizes, Prize, join_through: AttendeePrize

    field :badge_count, :integer, default: 0, virtual: true

    timestamps()
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:name, :nickname, :user_id])
    |> cast_attachments(attrs, [:avatar, :cv])
    |> cast_assoc(:user)
    |> validate_required([:name, :nickname])
    |> validate_format(:nickname, @nickname_regex)
    |> unique_constraint(:nickname)
  end

  def update_changeset_sign_up(attendee, attrs) do
    attendee
    |> cast(attrs, [:name, :nickname, :user_id])
    |> cast_attachments(attrs, [:avatar, :cv])
    |> cast_assoc(:user)
    |> validate_required([:name, :nickname])
    |> validate_format(:nickname, @nickname_regex)
    |> unique_constraint(:nickname)
  end

  def update_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:nickname])
    |> cast_attachments(attrs, [:avatar, :cv])
    |> validate_required([:nickname])
    |> validate_format(:nickname, @nickname_regex)
    |> unique_constraint(:nickname)
  end

  def update_changeset_discord_association(attendee, attrs) do
    attendee
    |> cast(attrs, [:discord_id])
  end

  def only_user_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:user_id, :name])
    |> cast_assoc(:user)
    |> validate_required([:user_id, :name])
  end

  def update_token_balance_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:token_balance])
    |> validate_required([:token_balance])
    |> validate_number(:token_balance,
      greater_than_or_equal_to: 0,
      message: "Token balance is insufficient."
    )
  end

  def update_entries_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:entries])
    |> validate_required([:entries])
    |> validate_number(:entries, greater_than_or_equal_to: 0)
  end

  def update_on_redeem_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:token_balance, :entries])
    |> validate_required([:token_balance, :entries])
    |> validate_number(:token_balance, greater_than_or_equal_to: 0)
    |> validate_number(:entries, greater_than_or_equal_to: 0)
  end
end

defmodule Safira.Accounts.Attendee do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User
  alias Safira.Contest.Redeem
  alias Safira.Contest.Badge
  alias Safira.Contest.Referral
  alias Safira.Store.Redeemable
  alias Safira.Store.Buy
  alias Safira.Roulette.Prize
  alias Safira.Roulette.AttendeePrize

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "attendees" do
    field :nickname, :string
    field :volunteer, :boolean, default: false
    field :avatar, Safira.Avatar.Type
    field :name, :string
    field :token_balance, :integer, default: 0
    field :discord_association_code, Ecto.UUID, autogenerate: true
    field :discord_id, :string

    belongs_to :user, User
    many_to_many :badges, Badge, join_through: Redeem
    has_many :referrals, Referral
    many_to_many :redeemables, Redeemable, join_through: Buy
    many_to_many :prizes, Prize, join_through: AttendeePrize

    field :badge_count, :integer, default: 0, virtual: true

    timestamps()
  end

  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:name, :nickname, :volunteer, :user_id])
    |> cast_attachments(attrs, [:avatar])
    |> cast_assoc(:user)
    |> validate_required([:name, :nickname, :volunteer])
    |> validate_length(:nickname, min: 2, max: 15)
    |> validate_format(:nickname, ~r/^[a-zA-Z0-9]+([a-zA-Z0-9](_|-)[a-zA-Z0-9])*[a-zA-Z0-9]+$/)
    |> unique_constraint(:nickname)
  end

  def update_changeset_sign_up(attendee, attrs) do
    attendee
    |> cast(attrs, [:name, :nickname, :user_id])
    |> cast_attachments(attrs, [:avatar])
    |> cast_assoc(:user)
    |> validate_required([:name, :nickname])
    |> validate_length(:nickname, min: 2, max: 15)
    |> validate_format(:nickname, ~r/^[a-zA-Z0-9]+([a-zA-Z0-9](_|-)[a-zA-Z0-9])*[a-zA-Z0-9]+$/)
    |> unique_constraint(:nickname)
  end

  def update_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:nickname])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:nickname])
    |> validate_length(:nickname, min: 2, max: 15)
    |> validate_format(:nickname, ~r/^[a-zA-Z0-9]+([a-zA-Z0-9](_|-)[a-zA-Z0-9])*[a-zA-Z0-9]+$/)
    |> unique_constraint(:nickname)
  end

  def update_changeset_discord_association(attendee, attrs) do
    attendee
    |> cast(attrs, [:discord_id])
  end

  def volunteer_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:volunteer])
    |> validate_required([:volunteer])
  end

  def only_user_changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:user_id, :name])
    |> cast_assoc(:user)
    |> validate_required([:user_id, :name])
  end
end

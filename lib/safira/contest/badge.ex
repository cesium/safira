defmodule Safira.Contest.Badge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Redeem
  alias Safira.Accounts.User

  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    field :name, :string
    field :description, :string

    many_to_many :users, User, join_through: Redeem
    has_one :company_user, User, foreign_key: :company_id

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [:begin, :end])
    |> validate_required([:begin, :end])
  end
end

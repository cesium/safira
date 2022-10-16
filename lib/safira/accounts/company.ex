defmodule Safira.Accounts.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User

  alias Safira.Contest.Badge

  schema "companies" do
    field :name, :string
    field :sponsorship, :string
    field :channel_id, :string
    field :remaining_spotlights, :integer
    belongs_to :user, User
    belongs_to :badge, Badge

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :sponsorship, :badge_id, :channel_id, :remaining_spotlights])
    |> cast_assoc(:user)
    |> cast(attrs, [:name, :sponsorship, :badge_id, :channel_id, :remaining_spotlights])
    |> validate_required([:name, :sponsorship, :badge_id, :channel_id])
    |> unique_constraint(:channel_id)
  end

  def start_spotlight_changeset(company, attrs) do
    company
    |> cast(attrs, [:remaining_spotlights])
    |> validate_number(:remaining_spotlights, greater_than_or_equal_to: 0)
  end
end

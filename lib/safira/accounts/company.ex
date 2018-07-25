defmodule Safira.Accounts.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge

  schema "companies" do
    field :name, :string
    field :sponsor, :string
    belongs_to :user, User
    belongs_to :badge, Badge

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :sponsor, :badge_id])
    |> cast_assoc(:user)
    |> validate_required([:name, :sponsor])
  end
end

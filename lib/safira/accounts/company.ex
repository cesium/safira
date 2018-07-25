defmodule Safira.Accounts.Company do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge

  schema "companies" do
    field :name, :string
    field :sponsorship, :string
    belongs_to :user, User
    belongs_to :badge, Badge

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :sponsorship, :badge_id])
    |> cast_assoc(:user)
    |> validate_required([:name, :sponsorship])
  end
end

defmodule Safira.Contest.Badge do
  use Ecto.Schema
  import Ecto.Changeset


  schema "badges" do
    field :begin, :utc_datetime
    field :end, :utc_datetime
    has_one :company, User, foreign_key: :company_id
    field :name, :string
    field :description, :string

    many_to_many :users, User, join_through: Redeem

    timestamps()
  end

  @doc false
  def changeset(badge, attrs) do
    badge
    |> cast(attrs, [:begin, :end])
    |> validate_required([:begin, :end])
  end
end

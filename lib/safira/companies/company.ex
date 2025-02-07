defmodule Safira.Companies.Company do
  @moduledoc """
  Companies present at the event.
  """
  use Safira.Schema

  alias Safira.Accounts.User

  @derive {
    Flop.Schema,
    filterable: [:name],
    sortable: [:name, :tier],
    default_limit: 11,
    join_fields: [
      tier: [
        binding: :tier,
        field: :priority,
        path: [:tier, :priority],
        ecto_type: :integer
      ]
    ]
  }

  @required_fields ~w(name tier_id user_id)a
  @optional_fields ~w(badge_id url)a

  schema "companies" do
    field :name, :string
    field :url, :string
    field :logo, Uploaders.Company.Type

    belongs_to :user, User
    belongs_to :badge, Safira.Contest.Badge
    belongs_to :tier, Safira.Companies.Tier

    timestamps(type: :utc_datetime)
    has_many :spotlights, Safira.Spotlights.Spotlight
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:badge_id)
    |> unique_constraint(:user_id)
    |> cast_assoc(:user, with: &User.profile_changeset/2)
    |> cast_assoc(:badge)
    |> cast_assoc(:tier)
    |> validate_url(:url)
    |> unsafe_validate_unique(:badge_id, Safira.Repo)
  end

  @doc false
  def image_changeset(company, attrs) do
    company
    |> cast_attachments(attrs, [:logo])
  end
end

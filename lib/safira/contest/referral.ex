defmodule Safira.Contest.Referral do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "referrals" do
    field :available, :boolean, default: true
    belongs_to :badge, Badge

    timestamps()
  end

  def changeset(referral, attrs) do
    referral
    |> cast(attrs, [:available])
    |> validate_required([:available])
  end
end

defmodule Safira.Contest.Referral do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Contest.Badge


  schema "referrals" do
    field :available, :boolean, default: false
    belongs_to :badge, Badge

    timestamps()
  end

  def changeset(referral, attrs) do
    referral
    |> cast(attrs, [:available])
    |> validate_required([:available])
  end
end

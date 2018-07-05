defmodule Safira.Contest.Referral do
  use Ecto.Schema
  import Ecto.Changeset


  schema "referrals" do
    field :available, :boolean, default: false
    field :badge_id, :id

    timestamps()
  end

  @doc false
  def changeset(referral, attrs) do
    referral
    |> cast(attrs, [:available])
    |> validate_required([:available])
  end
end

defmodule Safira.Store.Redeemable do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Store.Buy
  alias Safira.Accounts.Attendee

  schema "redeemables" do
    field(:img, Safira.Avatar.Type)
    field(:name, :string)
    field(:description, :string)
    field(:price, :integer)
    field(:redeem_limit, :integer)
    field(:num_redeems, :integer, default: 0)
    field(:max_per_user, :integer)

    many_to_many(:attendees, Attendee, join_through: Buy)

    timestamps()
  end

  def changeset(redeemable, attrs) do
    redeemable
    |> cast(attrs, [:name, :price, :redeem_limit, :num_redeems, :max_per_user])
    |> cast_attachments(attrs, [:img])
    |> validate_required([:name, :price, :redeem_limit, :num_redeems, :max_per_user])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:redeem_limit, greater_than: 0)
    |> validate_number(:num_redeems, greater_than: 0)
    |> validate_number(:max_per_user, greater_than: 0)
  end
end

defmodule Safira.Store.Redeemable do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Store.Buy
  alias Safira.Accounts.Attendee

  schema "redeemables" do
    field :img, Safira.Avatar.Type
    field :name, :string
    field :description, :string
    field :price, :integer
    field :stock, :integer
    field :max_per_user, :integer
    field :is_redeemable, :boolean, default: true

    many_to_many :attendees, Attendee, join_through: Buy

    timestamps()
  end

  def changeset(redeemable, attrs) do
    redeemable
    |> cast(attrs, [:name, :price, :stock, :max_per_user, :description, :is_redeemable])
    |> validate_required([:name, :price, :stock, :max_per_user, :description, :is_redeemable])
    |> cast_attachments(attrs, [:img])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:stock, greater_than_or_equal_to: 0, message: "Item is sold out!")
    |> validate_number(:max_per_user, greater_than: 0)
    |> validate_length(:description, min: 1, max: 1000)
  end
end

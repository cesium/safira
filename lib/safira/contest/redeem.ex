defmodule Safira.Contest.Redeem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.User
  alias Safira.Contest.Badge


  @primary_key false
  schema "users_badges" do
    belongs_to :attendee, User, foreign_key: :user_id
    belongs_to :badge, Badge, foreign_key: :badge_id
    belongs_to :staff, User, foreign_key: :staff_id

    timestamps()
  end

  @doc false
  def changeset(redeem, attrs) do
    redeem
    |> cast(attrs, [])
    |> validate_required([])
  end
end

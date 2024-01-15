defmodule Safira.Accounts.Staff do
  @moduledoc """
  A staff is a staff member who can give attendees badges and
  deliver them prizes they win throughout the event
  """
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.User
  alias Safira.Contest.Redeem

  schema "staffs" do
    field :active, :boolean, default: true
    field :is_admin, :boolean, default: false
    field :nickname, :string
    field :cv, Safira.CV.Type

    belongs_to :user, User
    has_many :redeems, Redeem

    timestamps()
  end

  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [:active, :is_admin, :nickname])
    |> cast_attachments(attrs, [:cv])
    |> cast_assoc(:user)
    |> validate_required([:active, :is_admin])
  end

  def update_cv_changeset(staff, attrs) do
    staff
    |> cast_attachments(attrs, [:cv])
  end
end

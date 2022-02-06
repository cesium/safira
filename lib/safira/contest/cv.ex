defmodule Safira.Contest.Cv do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.Attendee

  schema "cv" do
    belongs_to :user, Attendee
    field :cv, Safira.Cv.Type

    timestamps()
  end

  def changeset(cv, attrs) do
    cv 
    |> cast_assoc(:user)
    |> cast_attachments(attrs, [:cv])
  end
end

defmodule Safira.Contest.Cv do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.Attendee

  @primary_key {:id, autogenerate: true}
  schema "cv" do
    has_one :user, Attendee, on_delete: :delete_all
    field :cv, Safira.Cv.Type

    timestamps()
  end

  def changeset(cv, attrs) do
    cv |> cast_attachments(attrs, [:cv])
  end
end

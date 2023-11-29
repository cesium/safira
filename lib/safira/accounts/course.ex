defmodule Safira.Accounts.Course do
  @moduledoc """
  A course the user is enrolled in
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Safira.Accounts.Attendee

  @required_fields ~w(name)a

  schema "courses" do
    field :name, :string
    has_many :attendees, Attendee

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Safira.Activities.ActivityCategory do
  @moduledoc """
  Categories for activities.
  """
  use Safira.Schema

  @required_fields ~w(name)a

  schema "activity_categories" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity_category, attrs) do
    activity_category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

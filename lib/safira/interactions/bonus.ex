defmodule Safira.Interaction.Bonus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Safira.Accounts.Attendee
  alias Safira.Accounts.Company

  schema "bonuses" do
    field :count, :integer

    belongs_to :attendee, Attendee, foreign_key: :attendee_id, type: :binary_id
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(bonus, attrs) do
    bonus
    |> cast(attrs, [:count, :attendee_id, :company_id])
    |> validate_required([:count, :attendee_id, :company_id])
  end
end

defmodule Safira.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :redeemed_at, :naive_datetime
      add :type, :string, null: false

      add :attendee_id, references(:attendees, type: :binary_id, on_delete: :delete_all),
        null: false

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all)
      add :staff_id, references(:staffs, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end

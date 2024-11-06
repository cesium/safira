defmodule Safira.Repo.Migrations.CreateSpeakers do
  use Ecto.Migration

  def change do
    create table(:speakers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :picture, :string
      add :company, :string
      add :title, :string
      add :biography, :text
      add :highlighted, :boolean, default: false, null: false
      add :socials, :map

      timestamps(type: :utc_datetime)
    end
  end
end

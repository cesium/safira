defmodule Safira.Repo.Migrations.CreateFaqs do
  use Ecto.Migration

  def change do
    create table(:faqs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :answer, :string
      add :question, :string

      timestamps()
    end
  end
end

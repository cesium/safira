defmodule Safira.Repo.Migrations.AddCvToStaffs do
  use Ecto.Migration

  def change do
    alter table(:staffs) do
      add :cv, :string
    end
  end
end

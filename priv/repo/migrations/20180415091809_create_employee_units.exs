defmodule KeyGuard.Repo.Migrations.CreateEmployeeUnits do
  use Ecto.Migration

  def change() do
    create table(:employee_units) do
      add :employee_id, references(:employees, on_delete: :delete_all), null: false
      add :unit_id, references(:units, on_delete: :delete_all), null: false
    end

    create unique_index(:employee_units, [:employee_id, :unit_id])
  end
end

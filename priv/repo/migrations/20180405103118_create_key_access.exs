defmodule KeyGuard.Repo.Migrations.CreateKeyAccess do
  use Ecto.Migration

  def change() do
    create table(:key_access) do
      add :access_type, :boolean, null: false, default: false
      add :employee_id, references(:employees, on_delete: :delete_all), null: false
      add :key_id, references(:keys, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:key_access, [:employee_id, :key_id])
  end
end

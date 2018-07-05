defmodule KeyGuard.Repo.Migrations.CreateUnitKeys do
  use Ecto.Migration

  def change() do
    create table(:unit_keys) do
      add :unit_id, references(:units, on_delete: :delete_all), null: false
      add :key_id, references(:keys, on_delete: :delete_all, type: :string), null: false
    end

    create unique_index(:unit_keys, [:unit_id, :key_id])
  end
end

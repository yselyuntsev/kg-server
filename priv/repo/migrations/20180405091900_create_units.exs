defmodule KeyGuard.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change() do
    create table(:units) do
      add :name, :string, null: false, default: ""
      add :parent_id, references(:units, on_delete: :delete_all)
    end
  end
end

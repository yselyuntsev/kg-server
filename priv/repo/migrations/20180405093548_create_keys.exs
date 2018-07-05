defmodule KeyGuard.Repo.Migrations.CreateKeys do
  use Ecto.Migration

  def change() do
    create table(:keys, primary_key: false) do
      add :id, :string, primary_key: true, null: false
      add :color, :string, null: false, default: ""
      add :name, :string, null: false, default: ""
      add :extra, :string, null: false, default: ""
    end

    create unique_index(:keys, :id)
    create unique_index(:keys, :name)
  end
end

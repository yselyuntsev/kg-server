defmodule KeyGuard.Repo.Migrations.CreateKeysJournal do
  use Ecto.Migration

  def change() do
    create table(:keys_journal) do
      add :taken_at, :utc_datetime, null: false
      add :returned_at, :utc_datetime
      add :key_id, references(:keys, on_delete: :delete_all, type: :string), null: false
      add :taken_by, references(:employees, on_delete: :delete_all), null: false
      add :returned_by, references(:employees, on_delete: :delete_all)
    end
  end
end

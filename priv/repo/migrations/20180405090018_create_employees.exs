defmodule KeyGuard.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change() do
    create table(:employees) do
      add :first_name, :string, null: false, default: ""
      add :last_name, :string, null: false, default: ""
      add :patronym, :string, null: false, default: ""
      add :card, :string, null: false, default: ""
      add :encoded_photo, :string, null: false, default: "", size: 50_000
    end

    create unique_index(:employees, :card)
  end
end

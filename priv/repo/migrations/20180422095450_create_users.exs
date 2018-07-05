defmodule KeyGuard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change() do
    create table(:users) do
      add :username, :string, null: false, default: ""
      add :hashed_password, :string, null: false, default: ""
      add :token, :string, null: false, default: ""
      add :role, :integer, null: false
    end

    create unique_index(:users, :username)
    create unique_index(:users, :token)
  end
end

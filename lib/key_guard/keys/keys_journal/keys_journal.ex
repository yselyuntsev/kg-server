defmodule KeyGuard.Keys.KeysJournal do
  use Ecto.Schema

  schema "keys_journal" do
    belongs_to :key, KeyGuard.Keys.Key, type: :string
    belongs_to :taken_by_employee, KeyGuard.Staff.Employee, foreign_key: :taken_by
    belongs_to :returned_by_employee, KeyGuard.Staff.Employee, foreign_key: :returned_by

    field :taken_at, :utc_datetime
    field :returned_at, :utc_datetime
  end
end

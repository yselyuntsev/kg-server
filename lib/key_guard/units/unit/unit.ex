defmodule KeyGuard.Units.Unit do
  use Ecto.Schema
  alias KeyGuard.Keys.Key
  alias KeyGuard.Staff.Employee

  schema "units" do
    many_to_many :employees, Employee, join_through: "employee_units", on_delete: :delete_all, on_replace: :delete
    many_to_many :keys, Key, join_through: "unit_keys", on_delete: :delete_all, on_replace: :delete
    belongs_to :units, __MODULE__, foreign_key: :parent_id

    field :name, :string
  end
end

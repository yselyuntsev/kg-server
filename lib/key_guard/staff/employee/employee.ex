defmodule KeyGuard.Staff.Employee do
  use Ecto.Schema
  alias KeyGuard.Units.Unit

  schema "employees" do
    many_to_many :units, Unit, join_through: "employee_units", on_delete: :delete_all, on_replace: :delete

    field :first_name, :string
    field :last_name, :string
    field :patronym, :string
    field :card, :string
    field :encoded_photo, :string
  end
end

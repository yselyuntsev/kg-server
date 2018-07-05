defmodule KeyGuard.Keys.KeyAccess do
  use Ecto.Schema

  alias KeyGuard.Keys.Key
  alias KeyGuard.Staff.Employee

  schema "key_access" do
    belongs_to :key, Key, type: :string
    belongs_to :employee, Employee

    field :access_type, :boolean
  end
end

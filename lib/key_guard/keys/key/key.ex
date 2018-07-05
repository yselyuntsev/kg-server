defmodule KeyGuard.Keys.Key do
  use Ecto.Schema
  alias KeyGuard.Keys.KeyAccess
  alias KeyGuard.Units.Unit

  @primary_key {:id, :string, autogenerate: false}

  schema "keys" do
    has_many :key_access, KeyAccess, on_delete: :delete_all
    many_to_many :units, Unit, join_through: "unit_keys", on_delete: :delete_all, on_replace: :delete

    field :color, :string
    field :name, :string
    field :extra, :string
  end
end

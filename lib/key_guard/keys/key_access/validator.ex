defmodule KeyGuard.Keys.KeyAccess.Validator do
  @moduledoc "KeyAcces validation functions."

  alias KeyGuard.Keys.KeyAccess
  import Ecto.Changeset

  @create_required_fields [:key_id, :employee_id, :access_type]
  @update_required_fields [:access_type]

  @spec create_changeset(%KeyAccess{}, map) :: Ecto.Changeset.t()
  def create_changeset(key_access, params \\ %{}) do
    key_access
    |> cast(params, @create_required_fields)
    |> validate_required(@create_required_fields)
    |> unique_constraint(:key_id, name: :key_access_employee_id_key_id_index)
  end

  @spec update_changeset(%KeyAccess{}, map) :: Ecto.Changeset.t()
  def update_changeset(key_access, params \\ %{}),
    do: key_access |> cast(params, @update_required_fields) |> validate_required(@update_required_fields)
end

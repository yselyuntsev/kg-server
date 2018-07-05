defmodule KeyGuard.Keys.Key.Validator do
  @moduledoc "Key validation functions."

  alias KeyGuard.Keys.Key
  import Ecto.Changeset

  @create_required_fields [:id, :name, :color]
  @create_optional_fields [:extra]

  @update_required_fields [:name, :color]
  @update_optional_fields [:extra]

  @spec create_changeset(%Key{}, map) :: Ecto.Changeset.t()
  def create_changeset(key, params \\ %{}) do
    key
    |> cast(params, Enum.concat(@create_required_fields, @create_optional_fields))
    |> validate_required(@create_required_fields)
    |> unique_constraint(:id, name: :keys_pkey)
    |> validate_name_uniqueness()
    |> validate_name_lenght()
    |> validate_id_lenght()
  end

  @spec update_changeset(%Key{}, map) :: Ecto.Changeset.t()
  def update_changeset(key, params \\ %{}) do
    key
    |> cast(params, Enum.concat(@update_required_fields, @update_optional_fields))
    |> validate_required(@update_required_fields)
    |> validate_name_uniqueness()
    |> validate_name_lenght()
  end

  defp validate_name_lenght(changeset), do: validate_length(changeset, :name, max: 50)

  defp validate_id_lenght(changeset), do: validate_length(changeset, :id, max: 150)

  defp validate_name_uniqueness(changeset), do: unique_constraint(changeset, :name)
end

defmodule KeyGuard.Units.Unit.Validator do
  @moduledoc "Unit validation functions."

  alias KeyGuard.Units.Unit
  import Ecto.Changeset

  @required_fields [:name]
  @optional_field [:parent_id]

  @spec changeset(%Unit{}, map) :: Ecto.Changeset.t()
  def changeset(unit, params \\ %{}) do
    unit
    |> cast(params, Enum.concat(@required_fields, @optional_field))
    |> validate_required(@required_fields)
    |> validate_length(:name, max: 255)
    |> foreign_key_constraint(:parent_id)
  end
end
